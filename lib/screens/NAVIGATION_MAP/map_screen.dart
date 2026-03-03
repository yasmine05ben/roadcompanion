import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../HOME/homescreen.dart';
import 'navigation_service.dart';
import 'voice_instructor.dart';
import 'custom_search_bar.dart';
import 'emergency.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'incident_api_service.dart';
import 'dart:io';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/config.dart';
import 'dart:async'; // Add this import


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _destinationController = TextEditingController();
  LatLng _defaultLocation = LatLng(36.737232, 3.086472);
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  List<LatLng> _route = [];
  bool _isLoading = true;
  String _currentAddress = "جارٍ جلب العنوان...";
  SearchBarContentMode _contentMode = SearchBarContentMode.normal;
  LatLng? _reportedLocation;
  String? _reportedSubtypeLabel;
  List<Map<String, dynamic>> _incidents = [];
  bool _isFetchingIncidents = false;
  LatLng? _selectedMapLocation;
  bool _showIncidentsPanel = false;
  bool _userMovedMap = false;
  Timer? _refreshTimer;
  final Map<String, String> cautionIcons = {
    'حادث': 'assets/map_icons/1.png',
    'تصادم متسلسل': 'assets/map_icons/2.png',
    'عكس الاتجاه': 'assets/map_icons/3.png',
    'احتراق السيارة': 'assets/map_icons/4.png',
    'صدم المشاة': 'assets/map_icons/5.png',
    'انقلاب سيارة': 'assets/map_icons/6.png',
    'مسار مسدود': 'assets/map_icons/7.png',
    'المسار الأيسر': 'assets/map_icons/8.png',
    'المسار الأيمن': 'assets/map_icons/9.png',
    'المسار الأوسط': 'assets/map_icons/10.png',
    'ازدحام مروري': 'assets/map_icons/11.png',
    'ازدحام شديد': 'assets/map_icons/12.png',
    'توقف السيارات': 'assets/map_icons/13.png',
    'طقس سيء': 'assets/map_icons/14.png',
    'طريق زلق': 'assets/map_icons/15.png',
    'فيضانات': 'assets/map_icons/16.png',
    'ضباب': 'assets/map_icons/17.png',
    'خطر': 'assets/map_icons/18.png',
    'أشغال الطرق': 'assets/map_icons/19.png',
    'سقوط شيء': 'assets/map_icons/20.png',
    'حفرة': 'assets/map_icons/21.png',
    'إشارة معطلة':'assets/map_icons/22.png',
    'طريق مغلق': 'assets/map_icons/23.png',
    'صورة': 'assets/map_icons/24.png',
    'تعليق': 'assets/map_icons/25.png',
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchAllIncidents(); // Load all incidents initially

// Refresh incidents every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        // Refresh nearby incidents more frequently
        if (_currentLocation != null) {
          _fetchNearbyIncidents();
        }

        // Refresh all incidents less frequently (every 5 minutes)
        if (timer.tick % 10 == 0) { // 30s * 10 = 5 minutes
          _fetchAllIncidents();
        }
      }
    });
  }

  Future<String> _getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No auth token found.');

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['id'] ?? '';
      if (userId.isEmpty) throw Exception('User ID not found in token.');
      return userId;
    } catch (e) {
      throw Exception('Failed to decode token: $e');
    }
  }
  Future<void> _fetchAllIncidents() async {
    setState(() => _isFetchingIncidents = true);

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/incidents'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _incidents = List<Map<String, dynamic>>.from(data['incidents']);
          });
        }
      }
    } catch (e) {
      print('Error fetching all incidents: $e');
    } finally {
      setState(() => _isFetchingIncidents = false);
    }
  }

  Future<void> _fetchNearbyIncidents() async {
    if (_currentLocation == null) return;

    setState(() => _isFetchingIncidents = true);

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/incidents/nearby').replace(queryParameters: {
          'latitude': _currentLocation!.latitude.toString(),
          'longitude': _currentLocation!.longitude.toString(),
          'radius': '10000' // 5km radius
        }),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _incidents = List<Map<String, dynamic>>.from(data['incidents']);
            print('Fetched ${_incidents.length} incidents'); // Debug print

            // Debug print all incidents
            _incidents.forEach((incident) {
              print('''
            Incident: ${incident['subIncidentType']}
            Location: ${incident['location']['coordinates'][1]}, ${incident['location']['coordinates'][0]}
            User: ${incident['userId']}
            ''');
            });
          });
        }
      }
    } catch (e) {
      print('Error fetching incidents: $e');
    } finally {
      setState(() => _isFetchingIncidents = false);
    }
  }

  Future<void> _fetchIncidentsForLocation(LatLng location) async {
    if (!mounted) return;

    setState(() {
      _showIncidentsPanel = true;
      _isFetchingIncidents = true;
      _incidents = []; // Clear previous incidents
    });

    try {
      final uri = Uri.parse('${Config.baseUrl}/incidents/nearby')
          .replace(queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'radius': '10000' // Matches your backend's $maxDistance
      });

      print('Fetching from: ${uri.toString()}'); // Debug URL

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() => _incidents = List<Map<String, dynamic>>.from(data['incidents']));
        } else {
          throw Exception(data['message'] ?? 'Server returned false success');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('لا يوجد اتصال بالإنترنت');
    }  finally {
      if (mounted) {
        setState(() => _isFetchingIncidents = false);
      }
    }
  }

  void _handleMapTap(LatLng point) {
    setState(() {
      _selectedMapLocation = point;
      _showIncidentsPanel = true; // Ensure panel stays visible
    });

    // Don't clear incidents here - we want to keep showing them
    _fetchIncidentsForLocation(point);
    _mapController.move(point, _mapController.camera.zoom);
  }
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Stack(
            children: [
              Image.network('${Config.baseImageUrl}$imageUrl'),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentCard(Map<String, dynamic> incident) {
    bool hasPhoto = incident['photo'] != null && incident['photo'].isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.asset(
          cautionIcons[incident['subIncidentType']] ?? 'assets/warning/warning.png',
          width: 40,
          height: 40,
        ),
        title: Text(incident['subIncidentType'] ?? 'Incident'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (incident['comment'] != null && incident['comment'].isNotEmpty)
              Text(incident['comment'] ?? ''),
            if (hasPhoto)
              GestureDetector(
                onTap: () => _showFullImage(context, incident['photo']),
                child: Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF277DA1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo, size: 16, color: Color(0xFF277DA1)),
                      SizedBox(width: 4),
                      Text('عرض الصورة', style: TextStyle(color: Color(0xFF277DA1))),
                    ],
                  ),
                ),
              ),
          ],
        ),
        trailing: Text(
          '${DateTime.parse(incident['createdAt']).difference(DateTime.now()).inHours.abs()}h ago',
        ),
      ),
    );
  }

  Widget _buildIncidentsPanel() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الحوادث في هذه المنطقة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => _fetchIncidentsForLocation(_selectedMapLocation!),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showIncidentsPanel = false;

                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              _isFetchingIncidents
                  ? Center(child: CircularProgressIndicator())
                  : _incidents.isEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('لا توجد حوادث مُبلغ عنها في هذه المنطقة'),
              )
                  : Container(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: _incidents.map((incident) => _buildIncidentCard(incident)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _getUserLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خدمات تحديد الموقع معطلة. يرجى تفعيلها.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("مطلوب أذونات الموقع لاستخدام هذه الميزة.")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("Location fetched: ${position.latitude}, ${position.longitude}");

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      await _reverseGeocodeCurrentLocation();
      await _fetchNearbyIncidents(); // Add this line

      Future.delayed(Duration(milliseconds: 500), () {
        if (_currentLocation != null && mounted) {
          _mapController.move(_currentLocation!, 15.0);
        }
      });

      // In your _getUserLocation() method, update the position stream:
      Geolocator.getPositionStream().listen((Position position) {
        if (!mounted) return;

        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        // Only auto-center if user hasn't manually moved the map
        if (!_userMovedMap) {
          _mapController.move(_currentLocation!, _mapController.camera.zoom);
        }

        _reverseGeocodeCurrentLocation();
      });

    } catch (e) {
      print("خطأ في جلب الموقع: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في الحصول على الموقع. يرجى المحاولة مرة أخرى.")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _reverseGeocodeCurrentLocation() async {
    if (_currentLocation == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        localeIdentifier: 'ar', // For Arabic results if available
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        // Build address from available components
        List<String> addressParts = [];
        if (placemark.street != null) addressParts.add(placemark.street!);
        if (placemark.subLocality != null) addressParts.add(placemark.subLocality!);
        if (placemark.locality != null) addressParts.add(placemark.locality!);
        if (placemark.administrativeArea != null) addressParts.add(placemark.administrativeArea!);
        if (placemark.country != null) addressParts.add(placemark.country!);

        String address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}';

        setState(() {
          _currentAddress = address;
        });
      } else {
        setState(() {
          _currentAddress = '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      print("Reverse geocoding error: $e");
      setState(() {
        _currentAddress = '${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}';
      });
    }
  }

  Future<void> _setDestination() async {
    String destinationAddress = _destinationController.text.trim();
    if (destinationAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى إدخال عنوان الوجهة.")),
      );
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(destinationAddress);
      if (locations.isNotEmpty) {
        Location destination = locations.first;
        setState(() {
          _destinationLocation = LatLng(destination.latitude, destination.longitude);
        });

        List<LatLng> newRoute = await NavigationService.getRoute(
            _currentLocation!, _destinationLocation!);

        setState(() => _route = newRoute);
        _mapController.move(_destinationLocation!, 15.0);
        VoiceInstructor.speak("وجهتك تم تحديدها. استعد للانطلاق.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لم يتم العثور على عنوان الوجهة.")),
        );
      }
    } catch (e) {
      print("خطأ في تحديد الوجهة: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تحديد الوجهة. يرجى المحاولة مرة أخرى")),
      );
    }
  }

  void _startNavigation() async {

    setState(() {
      _userMovedMap = false;  // Reset the flag
    });

    if (_currentLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى تحديد الوجهة أولاً.")),
      );
      return;
    }

    try {
      List<LatLng> newRoute = await NavigationService.getRoute(
          _currentLocation!, _destinationLocation!);

      setState(() => _route = newRoute);
      VoiceInstructor.speak("تم بدء الملاحة، اتبع الطريق.");
    } catch (e) {
      print("خطأ في الحصول على الطريق:  $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في جلب الطريق. يرجى المحاولة مرة أخرى.")),
      );
    }
  }

  Widget _buildSideButtons() {
    return Positioned(
      bottom: 180,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmergencyContactsPage()),
              );
            },
            shape: CircleBorder(),
            backgroundColor: Color(0xFF277DA1),
            child: Image.asset(
              'assets/emergency.png',
              width: 50,
              height: 60,
            ),
          ),
          SizedBox(height: 14),
          FloatingActionButton(
            onPressed: () => _setSearchBarContentMode(SearchBarContentMode.caution),
            shape: CircleBorder(),
            backgroundColor: Color(0xFF277DA1),
            child: Image.asset(
              'assets/caution.png',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  void _setSearchBarContentMode(SearchBarContentMode mode) {
    setState(() => _contentMode = mode);
  }

  void _resetToNormal() {
    setState(() => _contentMode = SearchBarContentMode.normal);
  }


  void _handleReportConfirmation(String subtypeLabel, String type,
      {String? comment, String? imagePath, String? iconPath}) async {
    HapticFeedback.mediumImpact();

    try {
      String userId = await _getUserIdFromToken();
      File? imageFile = imagePath != null ? File(imagePath) : null;

      final success = await IncidentApiService.reportIncident(
        userId: userId,
        incidentType: type,
        subIncidentType: subtypeLabel,
        comment: comment,
        imageFile: imageFile,
        latitude: _currentLocation?.latitude ?? 0,
        longitude: _currentLocation?.longitude ?? 0,
      );

      if (success) {
        setState(() {
          _reportedLocation = _currentLocation;
          _reportedSubtypeLabel = subtypeLabel;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🚧 تم إرسال التحذير. شكراً لمساهمتك!")),
        );
        await _fetchNearbyIncidents(); // Refresh the incidents


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في إرسال التقرير. يرجى المحاولة مرة أخرى.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
            mapController: _mapController,
            options: // Update your MapOptions to include onPositionChanged:
            MapOptions(
              maxBounds: LatLngBounds(
                LatLng(-90, -180),
                LatLng(90, 180),
              ),
              initialCenter: _currentLocation ?? _defaultLocation,
              initialZoom: 15.0,
              onTap: (_, point) => _handleMapTap(point),
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _userMovedMap = true;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 50,
                      height: 50,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  if (_destinationLocation != null)
                    Marker(
                      point: _destinationLocation!,
                      width: 50,
                      height: 50,
                      child: Icon(Icons.location_pin, color: Colors.green, size: 40),
                    ),

                  ..._incidents.map((incident) {
                    return Marker(
                      point: LatLng(
                        incident['location']['coordinates'][1],
                        incident['location']['coordinates'][0],
                      ),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMapLocation = LatLng(
                              incident['location']['coordinates'][1],
                              incident['location']['coordinates'][0],
                            );
                            _showIncidentsPanel = true;
                          });
                        },
                        child: Image.asset(
                          cautionIcons[incident['subIncidentType'] ] ?? 'assets/map_icons/18.png',
                          width: 35,
                          height: 35,
                        ),
                      ),
                    );
                  }).toList(),


                ],
              ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route,
                      color: Colors.blue,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
              shape: CircleBorder(),
              backgroundColor: Color(0xFF277DA1),
              child: Icon(Icons.home, color: Colors.white, size: 35),
            ),
          ),

          Positioned(
            bottom: 180,
            left: 20,
            child: FloatingActionButton(
              onPressed: _startNavigation,
              shape: CircleBorder(),
              child: Icon(Icons.navigation, color: Colors.white),
              backgroundColor: Colors.red,
              elevation: 0,
            ),
          ),


          _buildSideButtons(),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomSearchBar(
              currentLocation: _currentAddress,
              latitude: _currentLocation?.latitude ?? 0.0,
              longitude: _currentLocation?.longitude ?? 0.0,
              destinationController: _destinationController,
              onSearch: _setDestination,
              contentMode: _contentMode,
              onResetToNormal: _resetToNormal,
              onConfirm: _handleReportConfirmation,
            ),
          ),
          // Add this to your stack of widgets:


          if (_showIncidentsPanel) _buildIncidentsPanel(),
        ],

      ),
    );
  }
}
