import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '/config.dart';

class RouteService {
  static Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
      }
      return [start, end]; // Fallback to straight line
    } catch (e) {
      print('Routing error: $e');
      return [start, end]; // Fallback to straight line
    }
  }
}

class ProviderScreen extends StatefulWidget {
  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  WebSocketChannel? _channel;
  Map<String, dynamic>? currentRequest;
  String? providerId;
  String? _token;
  bool isOnline = false;
  Position? currentPosition;
  List<LatLng> routePoints = [];
  bool isLoadingRoute = false;
  Stream<Position>? _positionStream;
  bool _isConnecting = false;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final String _websocketUrl = '${Config.wsUrl}/ws';
  bool serviceAccepted = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initProvider();
  }



  Future<void> _initProvider() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null && mounted) {
      final decoded = JwtDecoder.decode(_token!);
      setState(() {
        providerId = decoded['id'].toString();
      });
      _connectWebSocket();
      _initLocationTracking();
    }
  }

  void _connectWebSocket() {
    if (_isConnecting || _isConnected || providerId == null || _token == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) return;

    setState(() {
      _isConnecting = true;
      _reconnectAttempts++;
    });

    final wsUrl = Uri.parse('$_websocketUrl?userId=$providerId&token=$_token&type=provider');

    try {
      _channel = WebSocketChannel.connect(wsUrl);

      _channel?.sink.add(jsonEncode({
        "type": "register",
        "providerId": providerId,
      }));

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) => _handleDisconnection(),
        onDone: () => _handleDisconnection(),
        cancelOnError: true,
      );

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
          _reconnectAttempts = 0;
        });
      }

      if (isOnline) {
        _sendStatusUpdate(isOnline);
      }

    } catch (e) {
      _handleDisconnection();
    }
  }

  void _handleWebSocketMessage(dynamic message)  async {
    try {
      final data = jsonDecode(message);
      if (!mounted) return;

      switch (data['type']) {
        case 'new_request':
          setState(() {
            currentRequest = {
              'id': data['requestId'],
              'userId': data['userId'],
              'location': data['location'],
              'serviceType': data['serviceType'],
              'user': data['user'] ?? {'name': 'Unknown', 'phone': 'Not available'},
              'cancelledByUser': false,
            };

            if (data['pieceName'] != null) {
              currentRequest!['pieceName'] = data['pieceName'];
            }

            if (data['carModel'] != null) {
              currentRequest!['carModel'] = data['carModel'];
            }

            serviceAccepted = false;
            isLoadingRoute = true;
          });

          // Fetch initial route
          if (currentPosition != null) {
            final userLocation = currentRequest!['location'];
            final newRoute = await RouteService.getRoutePoints(
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
              LatLng(userLocation['lat'], userLocation['lng']),
            );

            if (mounted) {
              setState(() {
                routePoints = newRoute;
                isLoadingRoute = false;
              });
            }
          }
          break;

        case 'ping':
          _channel?.sink.add(jsonEncode({'type': 'pong'}));
          break;

        case 'accept_confirmation':
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Request accepted successfully!")));
          break;

        case 'request_cancelled':
          setState(() {
            currentRequest = {
              'id': data['requestId'],
              'cancelledByUser': true,
            };
            serviceAccepted = false;
          });
          break;

        default:
          print("Unknown message type: ${data['type']}");
      }
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  void _handleDisconnection() {
    if (!mounted) return;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
    });

    _channel?.sink.close();
    _channel = null;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      Future.delayed(Duration(seconds: _reconnectAttempts * 2), _connectWebSocket);
    }
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    );

    _positionStream!.listen((Position position) async {
      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoadingRoute = true;
      });

      _sendLocationUpdate(position);
      _mapController.move(LatLng(position.latitude, position.longitude), _mapController.camera.zoom);

      if (currentRequest != null && !currentRequest!['cancelledByUser']) {
        final userLocation = currentRequest!['location'];
        final newRoute = await RouteService.getRoutePoints(
          LatLng(position.latitude, position.longitude),
          LatLng(userLocation['lat'], userLocation['lng']),
        );

        if (mounted) {
          setState(() {
            routePoints = newRoute;
            isLoadingRoute = false;
          });
        }
      } else if (mounted) {
        setState(() => isLoadingRoute = false);
      }
    });
  }

  void _sendLocationUpdate(Position position) {
    if (_isConnected && _channel?.closeCode == null && providerId != null) {
      _channel?.sink.add(jsonEncode({
        'type': 'location_update',
        'lat': position.latitude,
        'lng': position.longitude,
        'providerId': providerId
      }));
    }
  }

  void _sendStatusUpdate(bool online) {
    if (_isConnected && _channel?.closeCode == null && providerId != null) {
      _channel?.sink.add(jsonEncode({
        'type': 'status_update',
        'providerId': providerId,
        'isOnline': online
      }));
    }
  }

  void _acceptRequest() {
    if (currentRequest == null || providerId == null || !_isConnected) return;

    _channel?.sink.add(jsonEncode({
      'type': 'accept_request',
      'requestId': currentRequest!['id'],
      'providerId': providerId
    }));

    if (mounted) {
      setState(() {
        serviceAccepted = true;
      });
    }
  }

  void _declineRequest() {
    if (mounted) {
      setState(() => currentRequest = null);
    }
  }

  void _completeService() {
    if (!_isConnected || providerId == null || currentRequest == null) return;

    _channel?.sink.add(jsonEncode({
      'type': 'complete_request',
      'providerId': providerId,
      'requestId': currentRequest!['id'],
    }));

    setState(() {
      currentRequest = null;
      serviceAccepted = false;
    });
  }

  void _cancelService() {
    if (!_isConnected || providerId == null || currentRequest == null) return;

    _channel?.sink.add(jsonEncode({
      'type': 'cancel_request',
      'providerId': providerId,
      'requestId': currentRequest!['id'],
    }));

    setState(() {
      currentRequest = null;
      serviceAccepted = false;
    });
  }

  void _toggleOnlineStatus(bool value) {
    if (mounted) {
      setState(() => isOnline = value);
    }
    _sendStatusUpdate(value);
  }

  void _manualReconnect() {
    if (mounted) {
      setState(() => _reconnectAttempts = 0);
    }
    _connectWebSocket();
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse("tel:$number");
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _launchSMS(String number) async {
    final uri = Uri.parse("sms:$number");
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _positionStream?.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF277DA1);
    const bgColor = Color(0xFFd7e6ec);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(child: Text("لوحة المزود", style: TextStyle(color: mainColor))),
        iconTheme: IconThemeData(color: mainColor),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: mainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _isConnected ? null : _manualReconnect,
            tooltip: _isConnected ? "متصل" : "غير متصل",
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: currentPosition != null
                  ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                  : LatLng(0, 0),
              zoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (currentPosition != null && currentRequest != null && !currentRequest!['cancelledByUser'])
                PolylineLayer(
                  polylineCulling: false,
                  polylines: [
                    // First condition: if we have route points
                    if (routePoints.isNotEmpty)
                      Polyline(
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),

                    // Second condition: if no route points but we have position and request
                    if (routePoints.isEmpty &&
                        currentPosition != null &&
                        currentRequest != null &&
                        !currentRequest!['cancelledByUser'])
                      Polyline(
                        points: [
                          LatLng(currentPosition!.latitude, currentPosition!.longitude),
                          LatLng(currentRequest!['location']['lat'], currentRequest!['location']['lng']),
                        ],
                        color: Colors.blue.withOpacity(0.3),
                        strokeWidth: 2.0,
                      ),
                  ],
                ),
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                      child: Icon(Icons.location_pin, color: mainColor, size: 40),
                    ),
                    if (currentRequest != null && !currentRequest!['cancelledByUser'])
                      Marker(
                        point: LatLng(currentRequest!['location']['lat'], currentRequest!['location']['lng']),
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                  ],
                ),
            ],
          ),

          if (currentRequest != null)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white.withOpacity(0.8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentRequest!['cancelledByUser'] == true)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => setState(() => currentRequest = null),
                            ),
                          Text(
                            "طلب خدمة",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      if (currentRequest!['cancelledByUser'] == true)
                        Text(
                          "❌ تم إلغاء هذا الطلب من قبل المستخدم",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.right,
                        )
                      else ...[
                        Text(
                          "نوع الخدمة: ${currentRequest!['serviceType']}",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),

                        if (currentRequest!['carModel'] != null) ...[
                          Text(
                            "موديل السيارة: ${currentRequest!['carModel']}",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 8),
                        ],

                        if (currentRequest!['pieceName'] != null) ...[
                          Text(
                            "القطعة المطلوبة: ${currentRequest!['pieceName']}",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 16),
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 8),
                        ],

                        Text(
                          "العميل: ${currentRequest!['user']['name']}",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "رقم الهاتف: ${currentRequest!['user']['phone']}",
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.phone, color: mainColor),
                              onPressed: () => _launchPhone(currentRequest!['user']['phone']),
                            ),
                            IconButton(
                              icon: Icon(Icons.message, color: mainColor),
                              onPressed: () => _launchSMS(currentRequest!['user']['phone']),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: serviceAccepted
                              ? [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _completeService,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text("إنهاء الخدمة"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cancelService,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text("إلغاء"),
                              ),
                            ),
                          ]
                              : [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isConnected ? _acceptRequest : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text("قبول الطلب"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _declineRequest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text("رفض الطلب"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isOnline ? "متاح لاستقبال الطلبات" : "غير متاح",
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: isOnline,
                      onChanged: _isConnected ? _toggleOnlineStatus : null,
                      activeColor: Colors.green,
                    )
                  ],
                ),
              ),
            ),
          ),

          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.red,
                child: Text(
                  "غير متصل بالخادم",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

}