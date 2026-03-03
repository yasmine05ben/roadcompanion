import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/screens/HOME/homescreen.dart';
import '/config.dart';
class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool colorPassword = false;
  bool colorConfirmPassword = false;
  String? errorPassword;
  String? errorConfirmPassword;
  bool error = false;

  final String _apiUrl = "${Config.baseUrl}/auth/reset-password";

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        errorPassword = "يجب إدخال كلمة المرور";
        colorPassword = true;
        error = true;
      });
    } else {
      setState(() {
        errorPassword = null;
        colorPassword = false;
      });
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        errorConfirmPassword = "يجب تأكيد كلمة المرور";
        colorConfirmPassword = true;
        error = true;
      });
    } else {
      setState(() {
        errorConfirmPassword = null;
        colorConfirmPassword = false;
      });
    }

    if (error == true) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        errorConfirmPassword = "كلمتا المرور غير متطابقتين";
        colorConfirmPassword = true;
        error = true;
      });
    }

    if (error == true) return;

    setState(() {
      errorPassword = null;
      errorConfirmPassword = null;
      colorPassword = false;
      colorConfirmPassword = false;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'newPassword': _passwordController.text.trim(),
          'confirmNewPassword': _confirmPasswordController.text.trim(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إعادة تعيين كلمة المرور بنجاح!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          errorPassword = data['message'] ?? "حدث خطأ، حاول مرة أخرى.";
          colorPassword = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في الاتصال: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 70),
                    Text(
                      "لنستعد حسابك !",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: Color(0xFF277DA1)),
                    ),
                    SizedBox(height: 20),

                    // Profile Image
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD7E6EC),
                      ),
                      child: Center(
                        child: Image.asset(
                          (colorPassword || colorConfirmPassword) ? 'assets/img_13.png' : 'assets/img_12.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    const SizedBox(
                      height: 60,
                      child: Text(
                        'من فضلك أدخل كلمة مرور جديدة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Password Input
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                labelStyle: TextStyle(
                                  color: Color(0xFF277DA1),
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: 'أدخل كلمة المرور',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Image.asset('assets/Icon.png', width: 20, height: 20),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: Color(0xFF277DA1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: colorPassword ? Colors.red : Colors.grey,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorPassword ? Colors.red.shade50 : Colors.white,
                              ),
                            ),
                          ),

                          if (colorPassword && errorPassword != null)
                            Padding(
                              padding: EdgeInsets.only(top: 5, right: 10),
                              child: Text(
                                errorPassword!,
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                            ),

                          SizedBox(height: 20),

                          // Confirm Password Input
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _isObscureConfirm,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                labelText: 'تأكيد كلمة المرور',
                                labelStyle: TextStyle(
                                  color: Color(0xFF277DA1),
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: 'أدخل تأكيد كلمة المرور',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Image.asset('assets/Icon.png', width: 20, height: 20),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscureConfirm ? Icons.visibility_off : Icons.visibility,
                                    color: Color(0xFF277DA1),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscureConfirm = !_isObscureConfirm;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                filled: true,
                                fillColor: colorConfirmPassword ? Colors.red.shade50 : Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(height: 50),

                          // Reset Password Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF9844A),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "إرسال",
                                style: TextStyle(fontSize: 22, color: Colors.white,fontWeight:FontWeight.w900 ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back Button in the top-left corner
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
    Navigator.pop(context);
    },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/arrow-left.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text(
              "رجوع",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
            ),
          ],
        ),
      ),
    );
  }
}

