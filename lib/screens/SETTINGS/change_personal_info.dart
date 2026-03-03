import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_field_screen.dart';
import '../../config.dart';

class ChangePersonalInfo extends StatefulWidget {
  const ChangePersonalInfo({super.key});

  @override
  State<ChangePersonalInfo> createState() => _ChangePersonalInfoState();
}

class _ChangePersonalInfoState extends State<ChangePersonalInfo> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();
  final TextEditingController proPhoneController = TextEditingController();
  final TextEditingController workPlaceController = TextEditingController();

  static const Color primaryColor = Color(0xFF277DA1);
  static const Color borderColor = Color(0xFFB9D3E1);
  static const Color backgroundColor = Color(0xFFFFFFFB);
  static const Color fieldFillColor = Color(0xFFF7FDFF);

  bool isLoading = true;
  String? profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("❌ Invalid Token: $e");
      return {};
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || JwtDecoder.isExpired(token)) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> payload = decodeToken(token);
      print("✅ Decoded JWT: $payload");

      String? relativePath = payload["profilePhoto"];
      profilePhotoUrl = (relativePath != null && relativePath.isNotEmpty)
          ? Config.baseImageUrl + '/' + relativePath
          : null;

      setState(() {
        firstNameController.text = payload["firstname"] ?? "غير متوفر";
        lastNameController.text = payload["lastname"] ?? "غير متوفر";
        emailController.text = payload["email"] ?? "غير متوفر";
        phoneController.text = payload["phone"] ?? "غير متوفر";
        accountTypeController.text = payload["role"] ?? "غير متوفر";
        proPhoneController.text = payload["phonePro"] ?? "غير متوفر";
        workPlaceController.text = payload["businessAddress"] ?? "غير متوفر";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null) return;

    final Map<String, dynamic> userData = {
      "email": emailController.text,
      "firstname": firstNameController.text,
      "lastname": lastNameController.text,
      "phone": phoneController.text,
      "phonePro": proPhoneController.text,
      "businessAddress": workPlaceController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/auth/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        prefs.setString('auth_token', responseData['token']);
        _loadUserData(); // Refresh
      }
    } catch (e) {
      _showDialog('خطأ في الشبكة', '❌ حدث خطأ أثناء الاتصال بالخادم');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textDirection: TextDirection.rtl),
        content: Text(message, textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            child: const Text('موافق'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToEditField(String label, TextEditingController controller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldScreen(
          fieldLabel: label,
          initialValue: controller.text,
          onSave: (newValue) {
            setState(() {
              controller.text = newValue;
            });
            _updateProfile();
          },
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {double inputFontSize = 16}) {
    final bool isEditable = label != 'نوع الحساب';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fieldFillColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isEditable
                ? GestureDetector(
              onTap: () => _navigateToEditField(label, controller),
              child: Text(
                controller.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: inputFontSize),
              ),
            )
                : Text(
              controller.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: inputFontSize),
            ),
          ),
          if (isEditable)
            const Icon(Icons.edit, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تعديل المعلومات الشخصية',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF277DA1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        buildTextField('الاسم', firstNameController),
                        buildTextField('اللقب', lastNameController),
                        buildTextField('البريد الالكتروني', emailController, inputFontSize: 12),
                        buildTextField('رقم الهاتف', phoneController),
                        buildTextField('نوع الحساب', accountTypeController),
                        buildTextField('رقم الهاتف المهني', proPhoneController),
                        buildTextField('مكان العمل', workPlaceController),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              child: profilePhotoUrl != null
                                  ? Image.network(
                                profilePhotoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset('assets/img_18.png', fit: BoxFit.contain),
                              )
                                  : Image.asset('assets/img_18.png', fit: BoxFit.contain),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor,
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: backgroundColor,
                          child: ClipOval(
                            child: profilePhotoUrl != null
                                ? Image.network(
                              profilePhotoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/img_18.png', width: 55, height: 55),
                            )
                                : Image.asset('assets/img_18.png', width: 55, height: 55),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
