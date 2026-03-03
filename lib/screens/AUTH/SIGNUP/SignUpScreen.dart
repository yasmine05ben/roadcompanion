import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'OTP.dart';
import '/config.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isObscure = true; // Track password visibility
  bool _isObscureConfirm = true;

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? errorEmail;
  String? errorPassword;
  String? errorConfirmPassword;
  String? errorPhone;

  bool colorEmail = false;
  bool colorPassword = false;
  bool colorConfirmPassword = false;
  bool colorPhone = false;
  Future<void> _signUp() async {
    bool hasError = false;

    // Email Validation
    if (_emailController.text.isEmpty) {
      setState(() {
        errorEmail = "الرجاء إدخال البريد الإلكتروني";
        colorEmail = true;
      });
      hasError = true;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      setState(() {
        errorEmail = "الرجاء إدخال بريد إلكتروني صالح";
        colorEmail = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorEmail = null;
        colorEmail = false;
      });
    }

    // Password Validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        errorPassword = "الرجاء إدخال كلمة المرور";
        colorPassword = true;
      });
      hasError = true;
    } else if (_passwordController.text.length < 8) {
      setState(() {
        errorPassword = "يجب أن تكون كلمة المرور 8 أحرف على الأقل";
        colorPassword = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorPassword = null;
        colorPassword = false;
      });
    }

    // Confirm Password Validation
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        errorConfirmPassword = "الرجاء تأكيد كلمة المرور";
        colorConfirmPassword = true;
      });
      hasError = true;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        errorConfirmPassword = "كلمة المرور غير متطابقة";
        colorConfirmPassword = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorConfirmPassword = null;
        colorConfirmPassword = false;
      });
    }

    // Phone Number Validation
    if (_phoneController.text.isEmpty) {
      setState(() {
        errorPhone = "الرجاء إدخال رقم الهاتف";
        colorPhone = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorPhone = null;
        colorPhone = false;
      });
    }

    if (hasError) return; // Stop if any validation fails

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'confirmPassword': _confirmPasswordController.text.trim(),
          'phone': _phoneController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Signup successful, navigate to home screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OTPVerificationScreen(email: _emailController.text.trim())),);
      } else {
        if (response.statusCode == 400) {
          final data = json.decode(response.body);

          setState(() {
            // Reset all previous error indicators
            errorPassword = null;
            colorPassword = false;
            errorConfirmPassword = null;
            colorConfirmPassword = false;
            errorPhone = null;
            colorPhone = false;
            errorEmail = null;
            colorEmail = false;

            // Check the message and assign the corresponding error
            final message = data['message'] ?? '';

            if (message.toLowerCase().contains('email')) {
              errorEmail = 'البريد الإلكتروني مستخدم بالفعل';
              colorEmail = true;
            } else if (message.toLowerCase().contains('phone')) {
              errorPhone = 'رقم الهاتف مستخدم بالفعل';
              colorPhone = true;
            }
          });
        }

      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    } finally {
      setState(() => _isLoading = false);
    }}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: ProsteThirdOrderBezierCurve(
                    position: ClipPosition.bottom,
                    list: [
                      ThirdOrderBezierCurveSection(
                        p1: Offset(2, 550),
                        p2: Offset(0, 150),
                        p3: Offset(screenWidth, 350),
                        p4: Offset(screenWidth, 100),
                      ),
                    ],
                  ),
                  child: Container(
                    height: 350,
                    width: screenWidth,
                    color: const Color(0xFFd7e6ec),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(
                          'assets/img_9.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 300,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'مرحبًا بك في "رفيق الطريق"!',
                      textAlign: TextAlign.center,textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF277DA1),
                      ),
                    ),
                  ),
                ),

              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height:50),

                      // Email Input
                      Directionality(
                        textDirection: TextDirection.rtl, // Enforce RTL
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        TextFormField(
                          controller: _emailController,
                          textAlign: TextAlign.right,

                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            labelStyle: TextStyle(
                              color: const Color(0xFF277DA1),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                            hintText: 'أدخل البريد الإلكتروني',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontFamily: 'Montserrat',
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/Iconemail_icon.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorEmail ? Colors.red : Colors.grey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorEmail ? Colors.red : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorEmail ? Colors.red : Color(0xFF277DA1), // Blue when focused
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: colorEmail ? Colors.red.shade50 : Colors.white,
                          ),
                        ),
                            if (colorEmail && errorEmail != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5, right: 10),
                                child: Text(
                                  errorEmail!,
                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                          ]
                        )
                      ),

                      const SizedBox(height: 25),

                      // Password Input
                      Directionality(
                        textDirection: TextDirection.rtl, // Enforce RTL
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          textAlign: TextAlign.right,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            labelStyle: TextStyle(
                              color: const Color(0xFF277DA1),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                            hintText: 'أدخل كلمة المرور',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontFamily: 'Montserrat',
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/Icon.png',
                                width: 20,
                                height: 20,
                              ),
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
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorPassword ? Colors.red : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorPassword ? Colors.red : Color(0xFF277DA1), // Change color when focused
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: colorPassword ? Colors.red.shade50 : Colors.white,
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
                          ]
                        )
                      ),

                      const SizedBox(height: 25.0,child:Text('كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، وتتضمن رقمًا.',textAlign:TextAlign.right,textDirection:TextDirection.rtl),),
                      Directionality(
                        textDirection: TextDirection.rtl, // Enforce RTL
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _isObscureConfirm,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            labelStyle: TextStyle(
                              color: const Color(0xFF277DA1),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                            hintText: 'أدخل كلمة المرور',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontFamily: 'Montserrat',
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/Icon.png',
                                width: 20,
                                height: 20,
                              ),
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
                              borderSide: BorderSide(
                                color: colorConfirmPassword ? Colors.red : Colors.grey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorConfirmPassword ? Colors.red : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorConfirmPassword ? Colors.red : Color(0xFF277DA1), // Change color when focused
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: colorConfirmPassword ? Colors.red.shade50 : Colors.white,
                          ),
                        ),
                            if (colorConfirmPassword && errorConfirmPassword != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5, right: 10),
                                child: Text(
                                  errorConfirmPassword!,
                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                          ]
                        )
                      ),
                      const SizedBox(height: 25.0),
                      Directionality(
                        textDirection: TextDirection.rtl, // Enforce RTL
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        TextFormField(
                          controller: _phoneController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            labelStyle: TextStyle(
                              color: const Color(0xFF277DA1),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                            hintText: 'أَدخل رقم هاتفك',
                            hintStyle: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontFamily: 'Montserrat',
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/iconphone.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorPhone ? Colors.red : Colors.grey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorPhone ? Colors.red : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: colorPhone ? Colors.red : Color(0xFF277DA1), // Change color when focused
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: colorPhone ? Colors.red.shade50 : Colors.white,
                          ),
                        ),
                            if (colorPhone && errorPhone != null)
                              Padding(
                                padding: EdgeInsets.only(top: 5, right: 10),
                                child: Text(
                                  errorPhone!,
                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                          ]
                        )
                      ),


                      const SizedBox(height: 25.0),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:_signUp ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF9844A),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25.0),



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

