import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'incident_api_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
enum SearchBarContentMode { normal, emergency, caution }

class CameraPermission {
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // First check if we have permission
    var status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Request permission normally
      status = await Permission.camera.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Show explanation before going to settings
      bool? shouldOpenSettings = await _showPermissionExplanationDialog(context);
      if (shouldOpenSettings ?? false) {
        await openAppSettings();
      }
      return false;
    }
    return false;
  }

  static Future<bool> requestPhotosPermission(BuildContext context) async {
    var status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await Permission.photos.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      bool? shouldOpenSettings = await _showPermissionExplanationDialog(context);
      if (shouldOpenSettings ?? false) {
        await openAppSettings();
      }
      return false;
    }
    return false;
  }

  static Future<bool?> _showPermissionExplanationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text('This app needs access to your camera/photos to function properly.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
final Map<String, List<Map<String, String>>> cautionSubtypes = {
  "حادث": [
    {"icon": "assets/accident/accident.png", "label": "حادث"},
    {"icon": "assets/accident/1.png", "label": "تصادم متسلسل"},
    {"icon": "assets/accident/2.png", "label": "عكس الاتجاه"},
    {"icon": "assets/accident/3.png", "label": "احتراق السيارة"},
    {"icon": "assets/accident/4.png", "label": "صدم المشاة"},
    {"icon": "assets/accident/5.png", "label": "انقلاب سيارة"},
  ],
  "مسار مسدود": [
    {"icon": "assets/block/block.png", "label": "مسار مسدود"},
    {"icon": "assets/block/1.png", "label": "المسار الأيسر"},
    {"icon": "assets/block/2.png", "label": "المسار الأيمن"},
    {"icon": "assets/block/3.png", "label": "المسار الأوسط "},
  ],
  "ازدحام مروري": [
    {"icon": "assets/traffic/traffic.png", "label": "مسار مسدود"},
    {"icon": "assets/traffic/1.png", "label": "ازدحام شديد"},
    {"icon": "assets/traffic/2.png", "label": "توقف السيارات"},
  ],
  "طقس سيء": [
    {"icon": "assets/cloud/cloud.png", "label": "طقس سيئ"},
    {"icon": "assets/cloud/1.png", "label": "طريق زلق"},
    {"icon": "assets/cloud/2.png", "label": "فيضانات"},
    {"icon": "assets/cloud/3.png", "label": "ضباب"},
  ],
  "خطر": [
    {"icon": "assets/warning/warning.png", "label": "خطر"},
    {"icon": "assets/warning/1.png", "label": "أشغال الطرق"},
    {"icon": "assets/warning/2.png", "label": "سقوط شيء"},
    {"icon": "assets/warning/3.png", "label": "حفرة"},
    {"icon": "assets/warning/4.png", "label": "إشارة معطلة"},


  ],
  "طريق مغلق": [
    {"icon": "assets/route_ferme.png", "label": "طريق مغلق"},
  ],
};
final Map<String, String> cautionIcons = {
  'حادث': 'assets/accident/accident.png',
  'تصادم متسلسل': 'assets/accident/1.png',
  'عكس الاتجاه': 'assets/accident/2.png',
  'احتراق السيارة': 'assets/accident/3.png',
  'صدم المشاة': 'assets/accident/4.png',
  'انقلاب سيارة': 'assets/accident/5.png',
  'مسار مسدود': 'assets/block/block.png',
  'المسار الأيسر': 'assets/block/1.png',
  'المسار الأيمن': 'assets/block/2.png',
  'المسار الأوسط': 'assets/block/3.png',
  'ازدحام مروري': 'assets/traffic/traffic.png',
  'ازدحام شديد': 'assets/traffic/1.png',
  'توقف السيارات': 'assets/traffic/2.png',
  'طقس سيء': 'assets/cloud/cloud.png',
  'طريق زلق': 'assets/cloud/1.png',
  'فيضانات': 'assets/cloud/2.png',
  'ضباب': 'assets/cloud/3.png',
  'خطر': 'assets/warning/warning.png',
  'أشغال الطرق': 'assets/warning/1.png',
  'سقوط شيء': 'assets/warning/2.png',
  'حفرة': 'assets/warning/3.png',
  'إشارة معطلة': 'assets/warning/4.png',
  'طريق مغلق': 'assets/route_ferme.png',
  'صورة': 'assets/photo.png',
  'تعليق': 'assets/comment.png',
};

class CustomSearchBar extends StatefulWidget {
  final String currentLocation;
  final double latitude;  // Add these
  final double longitude;
  final TextEditingController destinationController;
  final VoidCallback onSearch;
  final SearchBarContentMode contentMode;
  final VoidCallback onResetToNormal;
  final Function(String subtypeLabel, String type, {String? comment, String? imagePath})? onConfirm;

  const CustomSearchBar({
    Key? key,
    required this.currentLocation,
    required this.latitude,  // Add these
    required this.longitude,
    required this.destinationController,
    required this.onSearch,
    required this.contentMode,
    required this.onResetToNormal,
    this.onConfirm, // 👈 add this line


  }) : super(key: key);

  @override

  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool isEmergencyMode = false;
  bool isCautionMode = false;
  String? selectedCautionType;
  String? selectedCautionItem;
  String? selectedSubtypeLabel;
  File? _selectedImage;
  TextEditingController _commentController = TextEditingController();
  bool _showCommentField = false;
  final String currentLang = 'ar'; // or 'fr' or 'en'


  List<Widget> get extraButtons {
    if (isEmergencyMode) {
      return [
        ElevatedButton(onPressed: () {}, child: Text('Call 911')),
        ElevatedButton(onPressed: () {}, child: Text('First Aid')),
      ];
    } else if (isCautionMode) {
      return [
        ElevatedButton(onPressed: () {}, child: Text('Accident')),
        ElevatedButton(onPressed: () {}, child: Text('Roadblock')),
        ElevatedButton(onPressed: () {}, child: Text('Weather')),
      ];
    }
    return [];
  }

  void toggleEmergency() {
    setState(() {
      isEmergencyMode = !isEmergencyMode;
      if (isEmergencyMode) isCautionMode = false;
    });
  }

  void toggleCaution() {
    setState(() {
      isCautionMode = !isCautionMode;
      if (isCautionMode) {
        isEmergencyMode = false;
        selectedCautionType = null; // reset previous selection
        selectedSubtypeLabel = null;
      }
    });
  }
  Future<String> _getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Replace with your actual token key

    if (token == null) {
      throw Exception('No auth token found.');
    }

    try {
      // Decode the JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // Extract the userId from the decoded token payload
      String userId = decodedToken['id'] ?? ''; // Replace 'userId' with the actual key from your token

      if (userId.isEmpty) {
        throw Exception('User ID not found in token.');
      }

      return userId;
    } catch (e) {
      throw Exception('Failed to decode token: $e');
    }
  }

  List<Widget> get emergencyButtons {
    return [
      ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.local_police),
        label: Text("أبلغ عن حادث"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
      ),
      ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.fire_truck),
        label: Text("أبلغ عن حريق"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
        ),
      ),
      // Add more buttons here if needed
    ];
  }

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentMode != widget.contentMode &&
        widget.contentMode == SearchBarContentMode.caution) {
      // reset caution selections when re-entering caution mode
      setState(() {
        selectedCautionType = null;
        selectedSubtypeLabel = null;
      });
    }

    if (widget.contentMode == SearchBarContentMode.normal) {
      // reset all state when going back to normal
      setState(() {
        isEmergencyMode = false;
        isCautionMode = false;
        selectedCautionType = null;
        selectedSubtypeLabel = null;
      });
    }
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return AnimatedSize(

        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFB9D3E1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Color(0xFFE2F0F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 15),

                if (widget.contentMode == SearchBarContentMode.normal) ...[
                  Text(
                    "Current Location: ${widget.currentLocation}",
                    style: TextStyle(
                      color: const Color(0xFF277DA1),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE2F0F6),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: widget.destinationController,
                        decoration: InputDecoration(
                          hintText: "أدخل وجهتك",
                          hintStyle: TextStyle(
                            color: Color(0xFF277DA1),
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, color: Color(0xFF277DA1)),
                            onPressed: widget.onSearch,
                          ),
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                  ),
                ] else
                  if (widget.contentMode == SearchBarContentMode.caution) ...[

                    if (selectedCautionType != null)
                      _buildSubtypeGrid(selectedCautionType!)
                    else
                      ...[

                        Row(
                          children: [
                            Spacer(), // Pushes the text to the center
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              // Reduced padding above text
                              child: Text(
                                'ماذا ترى؟',
                                style: TextStyle(
                                  color: const Color(0xFF277DA1),
                                  fontSize: 20,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Spacer(), // Keeps the icon on the far right
                            IconButton(
                              icon: Icon(Icons.close, size: 30),
                              // Bigger reset icon
                              color: Colors.white,
                              onPressed: _handleResetToNormal,
                            ),
                          ],
                        ),

                        SizedBox(height: 0),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildCautionItemWithAsset(
                                "assets/accident/accident.png", "حادث"),
                            _buildCautionItemWithAsset(
                                "assets/block/block.png", "مسار مسدود"),
                            _buildCautionItemWithAsset(
                                "assets/traffic/traffic.png", "ازدحام مروري"),
                            _buildCautionItemWithAsset(
                                "assets/cloud/cloud.png", "طقس سيء"),
                            _buildCautionItemWithAsset(
                                "assets/warning/warning.png", "خطر"),
                            _buildCautionItemWithAsset(
                                "assets/route_ferme.png", "طريق مغلق"),
                            _buildCautionItemWithAsset(
                                "assets/comment.png", "تعليق"),
                            _buildCautionItemWithAsset(
                                "assets/photo.png", "صورة"),
                          ],
                        ),
                      ],
                  ]
              ]

          ),
        )
    );
  }

  Widget _buildCautionItemWithAsset(String assetPath, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCautionType = label;
          _selectedImage = null;
          _commentController.clear();
          _showCommentField = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: selectedCautionItem == label ? Color(0xFF277DA1) : Color(
                  0x93E2EEF6), // Change color on select
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),

          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF277DA1),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSubtypeGrid(String type) {
    if (type == "تعليق") {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
                onPressed: () {
                  setState(() {
                    selectedCautionType = null;
                    selectedSubtypeLabel = null;
                    _selectedImage = null;       // Reset the selected image
                    _commentController.clear();  // Clear the comment
                    _showCommentField = false;   // Hide the comment field
                  });
                },
              ),
              Spacer(),
              Text(
                "تعليق",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF277DA1),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 28, color: Colors.white),
                onPressed: widget.onResetToNormal,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  textAlign: currentLang == 'ar' ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "...أدخل تعليقك هنا",
                    filled: true,
                    fillColor: Color(0xFFE2F0F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _commentController.text.isNotEmpty
                      ? _handleConfirmComment
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF277DA1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    currentLang == 'ar' ? 'تأكيد الإرسال' : 'Confirm Send',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),


          if (_showCommentField)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton.icon(
                onPressed: _commentController.text.isNotEmpty
                    ? _handleConfirmComment
                    : null,
                icon: Icon(Icons.abc_sharp),
                label: Text('تأكيد الإضافة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

        ],
      );
    }
    if (type == "صورة") {
      return Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
                onPressed: () {
                  setState(() {
                    selectedCautionType = null;
                    selectedSubtypeLabel = null;
                    _selectedImage = null;       // Clear any selected image
                    _commentController.clear();  // Clear comment text
                    _showCommentField = false;
                  });
                },
              ),
              Spacer(),
              Text(
                "صورة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF277DA1),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 28, color: Colors.white),
                onPressed: _handleResetToNormal,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt, color: Color(0xFFE2F0F6)),
                      label: Text(
                        "التقط صورة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF277DA1),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library, color: Color(0xFFE2F0F6)),
                      label: Text(
                        "من المعرض",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF277DA1),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      ),
                    ),
                  ],
                ),

                if (_selectedImage != null) ...[
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 14,
                          child: IconButton(
                            icon: Icon(Icons.close, size: 14, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _handlePhotoConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF277DA1),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      currentLang == 'ar' ? 'إضافة الصورة إلى الخريطة' : 'Add Photo to Map',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )

        ],
      );
    }


    // Normal subtype grid
    final items = cautionSubtypes[type] ?? [];

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
              onPressed: () {
                setState(() {
                  selectedCautionType = null;
                  selectedSubtypeLabel = null;
                  _selectedImage = null;
                  _commentController.clear();
                  _showCommentField = false;
                });
              },
            ),
            Spacer(),
            Text(
              type,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF277DA1),
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.close, size: 28, color: Colors.white),
              onPressed: _handleResetToNormal,
            ),
          ],
        ),

        GridView.count(

          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items.map((item) {
            return _buildSubtypeIconButton(item['icon']!, item['label']!);
          }).toList(),

        ),

        if (selectedSubtypeLabel != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSubtypeLabel = null;
                          _selectedImage = null;
                          _commentController.clear();
                          _showCommentField = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE2F0F6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          color: const Color(0xFF277DA1),
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Photo button
                    PopupMenuButton<String>(
                      icon: Icon(Icons.camera_alt, color: Color(0xFF277DA1)),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'camera',
                          child: Text('التقط صورة'),
                        ),
                        PopupMenuItem(
                          value: 'gallery',
                          child: Text('اختر من المعرض'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'camera') {
                          _takePhoto();
                        } else {
                          _pickImage();
                        }
                      },
                      offset: Offset(0, -100), // Adjust position as needed
                    ),

                    // Comment button
                    IconButton(
                      icon: Icon(
                        _showCommentField
                            ? Icons.comment
                            : Icons.add_comment,
                        color: _showCommentField
                            ? Colors.green
                            : Color(0xFF277DA1),
                      ),
                      onPressed: () {
                        setState(() {
                          _showCommentField = !_showCommentField;
                        });
                      },
                      tooltip: 'إضافة تعليق',
                    ),

                    // Confirm button
                    ElevatedButton(
                      onPressed: () {
                        if (widget.onConfirm != null) {
                          widget.onConfirm!(
                            selectedSubtypeLabel!,
                            selectedCautionType!,
                            comment: _commentController.text.isNotEmpty
                                ? _commentController.text
                                : null,
                            imagePath: _selectedImage?.path,
                          );
                        }
                        setState(() {
                          selectedSubtypeLabel = null;
                          selectedCautionType = null;
                          _selectedImage = null;       // Reset the selected image
                          _commentController.clear();  // Clear the comment
                          _showCommentField = false;   // Hide the comment field
                        });
                        _handleResetToNormal();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE2F0F6),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'تأكيد',
                        style: TextStyle(
                          color: const Color(0xFF277DA1),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Optional: Show comment input
              if (_showCommentField)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 2,
                    textAlign: currentLang == 'ar' ? TextAlign.right : TextAlign.left,
                    decoration: InputDecoration(
                      hintText: currentLang == 'ar' ? 'تعليق' : 'Comment',
                      hintStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), // Rounded corners
                        borderSide: BorderSide(
                          color: Colors.blue, // Color of the border
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Color(0xFF277DA1), // Custom enabled border color
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.teal, // Focused color
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Color(0xFFE2F0F6),
                    ),
                  ),
                ),


              // Optional: Show selected image preview
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 100,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),



      ],
    );
  }
  Future<void> _takePhoto() async {
    try {
      final hasPermission = await CameraPermission.requestCameraPermission(context);

      if (!hasPermission) {
        return; // Permission not granted
      }

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: ${e.toString()}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      // Check current status
      var status = await Permission.photos.status;

      // If permission was previously denied, show explanation
      if (status.isDenied || status.isRestricted) {
        // Request permission
        status = await Permission.photos.request();

        // If still not granted, show message and return
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('يجب منح إذن الوصول إلى المعرض لاختيار الصور'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }

      // If permanently denied, show dialog to open settings
      if (status.isPermanentlyDenied) {
        bool? shouldOpen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('الإذن مطلوب'),
            content: Text('يجب منح إذن الوصول إلى الصور من إعدادات التطبيق'),
            actions: [
              TextButton(
                child: Text('إلغاء'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('فتح الإعدادات'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (shouldOpen == true) {
          await openAppSettings();
        }
        return;
      }

      // Now pick the image
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الصورة: ${e.toString()}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }


  void _handleResetToNormal() {
    setState(() {
      isCautionMode = false;
      isEmergencyMode = false;
      selectedCautionType = null;
      selectedSubtypeLabel = null;
      _selectedImage = null;       // Clear any selected image
      _commentController.clear();  // Clear comment text
      _showCommentField = false;   // Hide comment field
    });
    widget.onResetToNormal();
  }

  void _handlePhotoConfirmation() async {
    if (_selectedImage == null) return;

    // Get current user ID
    String userId = await _getUserIdFromToken();

    // Call the API
    final success = await IncidentApiService.reportIncident(
      userId: userId,
      incidentType: "صورة",
      latitude: widget.latitude,
      longitude: widget.longitude,
      imageFile: _selectedImage,
    );

    if (success) {
      // Clear and reset
      setState(() {
        _selectedImage = null;
        selectedCautionType = null;
        selectedSubtypeLabel = null;
      });

      _handleResetToNormal();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLang == 'ar' ? 'تم إضافة الصورة إلى الخريطة' : 'Photo added to map')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLang == 'ar' ? 'فشل تحميل الصورة' : 'Failed to upload photo')),
      );
    }
  }

  Widget _buildSubtypeIconButton(String iconPath, String label) {
    final isSelected = selectedSubtypeLabel == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubtypeLabel = label;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xFFE2F0F6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Image.asset(iconPath, fit: BoxFit.contain),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(
                        Icons.check, size: 14, color: Color(0xFFE2F0F6)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.green : Color(0xFF277DA1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirmComment() async {
    final String comment = _commentController.text.trim();

    if (comment.isEmpty) return;

    // Get current user ID
    String userId = await _getUserIdFromToken();

    // Call the API
    final success = await IncidentApiService.reportIncident(
      userId: userId,
      incidentType: "تعليق",
      latitude: widget.latitude,
      longitude: widget.longitude,
      comment: comment,
    );

    if (success) {
      // Clear and reset
      setState(() {
        _commentController.clear();
        selectedCautionType = null;
        selectedSubtypeLabel = null;
      });

      _handleResetToNormal();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLang == 'ar' ? 'تم إرسال التعليق بنجاح' : 'Comment submitted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentLang == 'ar' ? 'فشل إرسال التعليق' : 'Failed to submit comment')),
      );
    }
  }
}

