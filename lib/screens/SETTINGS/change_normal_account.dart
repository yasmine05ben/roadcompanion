import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'edit_field_screen.dart';

class ChangeNormalAccount extends StatefulWidget {
  const ChangeNormalAccount({super.key});

  @override
  State<ChangeNormalAccount> createState() => _ChangeNormalAccountState();
}

class _ChangeNormalAccountState extends State<ChangeNormalAccount> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  static const Color primaryColor = Color(0xFF277DA1);
  static const Color borderColor = Color(0xFFB9D3E1);
  static const Color backgroundColor = Color(0xFFFFFFFB);
  static const Color fieldFillColor = Color(0xFFF7FDFF);

  bool isLoading = true;
  String? errorMessage;
  String? oldEmail;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("❌ Invalid Token: $e");
      return {};
    }
  }
  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || JwtDecoder.isExpired(token)) {
        setState(() {
          errorMessage = "الرمز مفقود أو منتهي الصلاحية";
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> payload = decodeToken(token);
      print("✅ Decoded JWT: $payload");

      setState(() {
        firstNameController.text = payload["firstname"] ?? "غير متوفر";
        lastNameController.text = payload["lastname"] ?? "غير متوفر";
        emailController.text = payload["email"] ?? "غير متوفر";
        phoneController.text = payload["phone"] ?? "غير متوفر";
        oldEmail = payload["email"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "حدث خطأ أثناء جلب البيانات";
        isLoading = false;
      });
    }
  }

  Future<bool> updateProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        _showDialog('خطأ', 'لم يتم العثور على رمز المستخدم');
        return false;
      }

      final url = Uri.parse('${Config.baseUrl}/auth/update-profile');

      print('🔵 Sending update with:');
      print({
        'email': oldEmail,
        'newEmail': emailController.text,
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'phone': phoneController.text,
      });
      print('🔵 Token: $token');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': oldEmail,
          'newEmail': emailController.text,
          'firstname': firstNameController.text,
          'lastname': lastNameController.text,
          'phone': phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Update success: ${response.body}");

        final responseData = jsonDecode(response.body);
        String? newToken = responseData['token'];

        if (newToken != null) {
          await prefs.setString('auth_token', newToken);
          print("🔵 New token saved to SharedPreferences");
        } else {
          print("⚠️ No newToken found in response");
        }

        return true;
      } else {
        print('❌ Update failed: Status ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error during update: $e');
      return false;
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
          onSave: (newValue) async {
            bool success;

            final oldValue = controller.text;
            controller.text = newValue;

            success = await updateProfile();

            if (success) {
              _showDialog('تم التحديث', '✅ تم تحديث المعلومات بنجاح');
            } else {
              controller.text = oldValue;
              _showDialog('خطأ', '❌ فشل تحديث المعلومات');
            }

            setState(() {});
          },
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {double inputFontSize = 16}) {
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
            : errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        )
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
                        buildTextField('البريد الالكتروني', emailController, inputFontSize: 13),
                        buildTextField('رقم الهاتف', phoneController),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: backgroundColor,
                            border: Border.all(color: borderColor, width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/img_18.png'),
                            backgroundColor: backgroundColor,
                          ),
                        ),
                      ],
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
