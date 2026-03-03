import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raodsafety/config.dart'; // Your Config file
import '../AUTH/login.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  static const Color primaryColor = Color(0xFF277DA1);
  static const Color backgroundColor = Color(0xFFFFFFFB);
  static const Color buttonColor = Color(0xFFF9844A);
  static const Color borderColor = Color(0xFFB9D3E1);

  void _handleDelete() async {
    final password = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showDialog('خطأ', 'جميع الحقول مطلوبة');
    } else if (password != confirm) {
      _showDialog('تحذير', 'كلمتا المرور غير متطابقتين');
    } else {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token') ?? '';

        // Decode token to extract email
        final email = _getEmailFromToken(token);
        if (email.isEmpty) {
          _showDialog('خطأ', 'رمز التوثيق غير صالح أو لم يتم العثور على البريد الإلكتروني');
          return;
        }

        final request = http.Request(
          'DELETE',
          Uri.parse('${Config.baseUrl}/auth/delete-account'),
        );

        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        });

        request.body = jsonEncode({
          'email': email,
          'password1': password,
          'password2': confirm,
        });
        print('⏱️ Sending DELETE request to: ${Config.baseUrl}/auth/delete-account');
        print('🔐 Headers: ${request.headers}');
        print('📦 Body: ${jsonEncode(request.body)}');

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          await prefs.remove('auth_token');
          await prefs.setBool('first_time', true); // ✅ Définir le booléen
          _showDialog('نجاح', 'تم حذف الحساب بنجاح', navigateAfter: true);
        } else {
          String errorMessage = 'حدث خطأ أثناء حذف الحساب';
          try {
            final responseData = jsonDecode(response.body);

            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            } else if (responseData.containsKey('detail')) {
              errorMessage = responseData['detail'];
            } else if (responseData.containsKey('error') && responseData['error'] is Map) {
              final error = responseData['error'];
              if (error.containsKey('message')) {
                errorMessage = error['message'];
              }
            }

            if (errorMessage.contains('Mot de passe incorrect')) {
              errorMessage = 'كلمة المرور غير صحيحة';
            }
          } catch (_) {
            errorMessage = response.body;
          }

          _showDialog('خطأ', errorMessage);
        }
      } catch (e) {
        _showDialog('خطأ', '⚠️ فشل الاتصال بالخادم: ${e.toString()}');
      }
    }
  }

  String _getEmailFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return '';
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      return payloadMap['email'] ?? '';
    } catch (e) {
      return '';
    }
  }

  void _showDialog(String title, String message, {bool navigateAfter = false}) {
    final bool isError = ['خطأ', 'تحذير', 'كلمة مرور ضعيفة'].contains(title);
    final bool isSuccess = title == 'نجاح';

    final Color titleColor = isError
        ? const Color(0xFFC52C38)
        : isSuccess
        ? const Color(0xFF81ED9B)
        : Colors.black;

    showDialog(
      context: context,
      barrierDismissible: !isSuccess,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          actions: isSuccess
              ? []
              : [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'رجوع',
                  style: TextStyle(color: titleColor),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) async {
      if (navigateAfter && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'حذف الحساب',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
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
                        child: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'أنت على وشك حذف حسابك بشكل دائم.\nهذا الإجراء لا يمكن التراجع عنه.\nيرجى تأكيد كلمة المرور لمتابعة العملية.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 26),
              _buildPasswordField(
                label: 'كلمة المرور',
                controller: passwordController,
                obscure: obscurePassword,
                toggleVisibility: () {
                  setState(() => obscurePassword = !obscurePassword);
                },
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                label: 'تأكيد كلمة المرور',
                controller: confirmPasswordController,
                obscure: obscureConfirm,
                toggleVisibility: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
                icon: Icons.lock,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'حذف الحساب',
                    style: TextStyle(
                      fontSize: 22,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggleVisibility,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.black, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
