import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
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
class Normal1UserScreen extends StatefulWidget {
  @override
  _Normal1UserScreenState createState() => _Normal1UserScreenState();
}

class _Normal1UserScreenState extends State<Normal1UserScreen> {
  WebSocketChannel? _channel;
  String? userId;
  String? _token;
  LatLng? userLocation;
  LatLng? providerLocation;
  String? providerName;
  String? providerPhone;
  String? requestId;
  bool isWaiting = false;
  bool _isConnected = false;
  String? _requestStatusMessage;

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      final decoded = JwtDecoder.decode(_token!);
      setState(() => userId = decoded['id'].toString());
      await _getUserLocation();
      _connectWebSocket();
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => userLocation = LatLng(position.latitude, position.longitude));
    _mapController.move(userLocation!, 14);
  }

  void _connectWebSocket() {
    if (userId == null || _token == null) return;

    final wsUrl = Uri.parse('${Config.wsUrl}/ws?userId=$userId&token=$_token');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel?.stream.listen(
      _handleWebSocketMessage,
      onError: (error) => _reconnectWebSocket(),
      onDone: _reconnectWebSocket,
    );

    _channel?.sink.add(jsonEncode({
      "type": "register",
      "userId": userId,
    }));

    setState(() => _isConnected = true);
  }

  List<LatLng> routePoints = []; // Add this variable

  void _handleWebSocketMessage(dynamic message) async {
    try {
      final data = jsonDecode(message);

      if (data['type'] == 'request_accepted') {
        setState(() {
          isWaiting = false;
          providerName = data['provider']['name'];
          providerPhone = data['provider']['phone'];
          providerLocation = LatLng(
            data['provider']['location']['lat'],
            data['provider']['location']['lng'],
          );
          requestId = data['requestId'];
          _requestStatusMessage = null;
        });
        // Fetch initial route
        if (userLocation != null && providerLocation != null) {
          final points = await RouteService.getRoutePoints(userLocation!, providerLocation!);
          setState(() => routePoints = points);
        }
      }
      else if (data['type'] == 'provider_location') {
        final loc = data['location'];
        final newProviderLocation = LatLng(loc['lat'], loc['lng']);
        setState(() => providerLocation = newProviderLocation);

        // Recalculate route when provider moves
        if (userLocation != null) {
          final points = await RouteService.getRoutePoints(userLocation!, newProviderLocation);
          setState(() => routePoints = points);
        }
      }
      else if (data['type'] == 'request_cancelled') {
        setState(() {
          isWaiting = false;
          providerName = null;
          providerPhone = null;
          providerLocation = null;
          requestId = null;
          routePoints = []; // Clear route
          _requestStatusMessage = "تم إلغاء الطلب من قبل المزود.";
        });
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void _reconnectWebSocket() {
    if (mounted) {
      setState(() => _isConnected = false);
      Future.delayed(Duration(seconds: 5), _connectWebSocket);
    }
  }

  Future<void> _sendRequest() async {
    if (userLocation == null || userId == null) return;

    setState(() {
      isWaiting = true;
      _requestStatusMessage = null;
      requestId = Uuid().v4(); // Generate temporary requestId
    });

    _channel?.sink.add(jsonEncode({
      'type': 'new_request',
      'userId': userId,
      'serviceType': "عامل سحب السيارات",
      'lat': userLocation!.latitude,
      'lng': userLocation!.longitude,
      'requestId': requestId, // include this in payload
    }));
  }

  void _cancelRequest() {
    if (userId == null || requestId == null) return;

    _channel?.sink.add(jsonEncode({
      "type": "cancel_request",
      "userId": userId,
      "requestId": requestId,
    }));

    setState(() {
      isWaiting = false;
      providerName = null;
      providerPhone = null;
      providerLocation = null;
      requestId = null;
      _requestStatusMessage = "تم إلغاء الطلب من قبلك.";
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() => userLocation = newLocation);
        _mapController.move(newLocation, 14);
      }
    } catch (e) {
      _showErrorSnackbar("لم يتم العثور على الموقع");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _recenterMap() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() => userLocation = newLocation);
      _mapController.move(newLocation, _mapController.camera.zoom);
    } catch (e) {
      _showErrorSnackbar("تعذر تحديد الموقع الحالي");
    }
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
    _searchController.dispose();
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
        iconTheme: IconThemeData(color: mainColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: mainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const SizedBox(width: 70), // adjust this to control how far left it goes
            Text("طلب خدمة", style: TextStyle(color: mainColor)),
          ],
        ),
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: userLocation ?? LatLng(0, 0), zoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (userLocation != null && providerLocation != null)
                PolylineLayer(
                  polylines: [
                    if (routePoints.isNotEmpty)
                      Polyline(
                        points: routePoints, // Use the dynamic route points
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    // Fallback: Straight line if no route points
                    if (routePoints.isEmpty && userLocation != null && providerLocation != null)
                      Polyline(
                        points: [userLocation!, providerLocation!],
                        color: Colors.blue.withOpacity(0.3),
                        strokeWidth: 2.0,
                        isDotted: true,
                      ),
                  ],
                ),
              if (userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      child: Icon(Icons.location_pin, color: mainColor, size: 40),
                    ),
                    if (providerLocation != null)
                      Marker(
                        point: providerLocation!,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                  ],
                ),
            ],
          ),
          if (_requestStatusMessage != null || (providerName != null && providerPhone != null))
            Positioned(
              top:  10,
              left: 16,
              right: 16,
              child: _requestStatusMessage != null
                  ? Card(
                color: Colors.white.withOpacity(0.7),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    _requestStatusMessage!,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _requestStatusMessage = null;
                      });
                    },
                  ),
                ),
              )
                  : Card(
                color: Colors.white.withOpacity(0.7),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text("المزود: $providerName", textAlign: TextAlign.right,textDirection:TextDirection.rtl),
                  subtitle: Text("رقم الهاتف: $providerPhone", textAlign: TextAlign.right),
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                          icon: Icon(Icons.phone, color: mainColor),
                          onPressed: () => _launchPhone(providerPhone!)
                      ),
                      IconButton(
                          icon: Icon(Icons.location_on, color: mainColor),
                          onPressed: () {
                            if (providerLocation != null) {
                              _mapController.move(providerLocation!, 14);
                            }
                          }
                      ),
                      IconButton(
                          icon: Icon(Icons.message, color: mainColor),
                          onPressed: () => _launchSMS(providerPhone!)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'ابحث عن موقع...',
                      prefixIcon: Icon(Icons.search, color: mainColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (value) => _searchLocation(value),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    minimumSize: Size(100, 50),
                  ),
                  child: Text("طلب عامل سحب السيارات", style: TextStyle(color: Colors.white)),
                ),
                if (isWaiting && providerName == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                if (isWaiting || requestId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: _cancelRequest,
                      icon: Icon(Icons.cancel, color: Colors.red),
                      label: Text("إلغاء الطلب", style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: mainColor,
              onPressed: _recenterMap,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
