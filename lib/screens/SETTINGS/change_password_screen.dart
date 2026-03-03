import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart'; // Adjust the path if needed

String? extractEmailFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = jsonDecode(decoded);

    return payloadMap['email']; // assuming your token contains 'email'
  } catch (e) {
    return null;
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color headerColor = Color(0xFF277DA1); // Blue
    const Color buttonColor = Color(0xFFF9844A); // Orange

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
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
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تغيير كلمة المرور',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: headerColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'يرجى إدخال كلمة المرور الحالية والجديدة لتحديثها',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),
                _buildLabeledPasswordField(
                  labelAbove: 'كلمة المرور الحالية',
                  hint: 'أدخل كلمة المرور الحالية',
                  isVisible: _oldPasswordVisible,
                  onToggleVisibility: () {
                    setState(() => _oldPasswordVisible = !_oldPasswordVisible);
                  },
                  obscure: !_oldPasswordVisible,
                  controller: _oldPasswordController,
                ),
                const SizedBox(height: 20),
                _buildLabeledPasswordField(
                  labelAbove: 'كلمة المرور الجديدة',
                  hint: 'أدخل كلمة المرور الجديدة',
                  isVisible: _newPasswordVisible,
                  onToggleVisibility: () {
                    setState(() => _newPasswordVisible = !_newPasswordVisible);
                  },
                  obscure: !_newPasswordVisible,
                  controller: _newPasswordController,
                ),
                const SizedBox(height: 20),
                _buildLabeledPasswordField(
                  labelAbove: 'تأكيد كلمة المرور',
                  hint: 'أعد كتابة كلمة المرور الجديدة',
                  isVisible: _confirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
                  },
                  obscure: !_confirmPasswordVisible,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handlePasswordChange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFFFFFFFB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledPasswordField({
    required String labelAbove,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required bool obscure,
    required TextEditingController controller,
  }) {
    const Color borderColor = Color(0xFFB9D3E1); // Light blue
    const Color labelColor = Color(0xFF277DA1); // Blue

    IconData icon = Icons.lock_outline;
    if (labelAbove.contains('الجديدة') && !labelAbove.contains('تأكيد')) {
      icon = Icons.lock;
    } else if (labelAbove.contains('تأكيد')) {
      icon = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: labelColor, size: 20),
            const SizedBox(width: 6),
            Text(
              labelAbove,
              style: const TextStyle(
                fontSize: 17,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  void _handlePasswordChange() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final String? userEmail = extractEmailFromToken(token ?? '');

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showDialog('خطأ', 'جميع الحقول مطلوبة');
    } else if (userEmail == null || userEmail.isEmpty) {
      _showDialog('خطأ', 'لم يتم العثور على البريد الإلكتروني للمستخدم');
    } else if (newPassword != confirmPassword) {
      _showDialog('تحذير', 'كلمتا المرور غير متطابقتين');
    } else if (newPassword.length < 6) {
      _showDialog('ضعف كلمة المرور', 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، مع وجود رقم وحرف');
    } else if (newPassword == oldPassword) {
      _showDialog('تحذير', 'يجب أن تكون كلمة المرور الجديدة مختلفة عن القديمة');
    } else {
      final passwordRegex = RegExp(r'^(?=.*\d)(?=.*[a-zA-Z]).{8,}$');
      if (!passwordRegex.hasMatch(newPassword)) {
        _showDialog('ضعف كلمة المرور', 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، مع وجود رقم وحرف');
        return;
      }

      try {
        final response = await http.patch(
          Uri.parse('${Config.baseUrl}/auth/change-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail,
            'ancienPassword': oldPassword,
            'nouveauPassword1': newPassword,
            'nouveauPassword2': confirmPassword,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          _showDialog('نجاح', 'تم تغيير كلمة المرور بنجاح');
        } else {
          String errorMessage = responseData['message'] ?? 'حدث خطأ أثناء تغيير كلمة المرور';

          // Translate the French error message to Arabic
          if (errorMessage.contains("Ancien mot de passe incorrect")) {
            errorMessage = "كلمة المرور القديمة غير صحيحة";
          }

          _showDialog('خطأ', errorMessage);
        }
      } catch (e) {
        _showDialog('خطأ', 'فشل الاتصال بالخادم');
      }
    }
  }

  void _showDialog(String title, String message) {
    final bool isError = ['خطأ', 'تحذير', 'ضعف كلمة المرور'].contains(title);
    final bool isSuccess = title == 'نجاح';

    final Color titleColor = isError
        ? const Color(0xFFC52C38)
        : isSuccess
        ? const Color(0xFF81ED9B)
        : Colors.black;

    const Color backgroundColor = Color(0xFFFFFFFB);

    String friendlyMessage = message; // Default message

    showDialog(
      context: context,
      barrierDismissible: !isSuccess, // Allow dismiss only for success
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (isSuccess && mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        });

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
            friendlyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          actions: isSuccess
              ? [] // No action buttons for success
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
    );
  }
}
