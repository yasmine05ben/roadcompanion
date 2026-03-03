import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'SIGNUP/SignUpScreen.dart';
import '../HOME/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FORGOTPASS/verfemail.dart';
import '/config.dart';
import '../ADMIN/admin_dashboard.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true; // Track password visibility
  final _formKey = GlobalKey<FormState>();
  String? errorEmail, errorPassword;
  bool colorEmail = false, colorPassword = false;
  // Backend API URL
  final String _apiUrl = "${Config.baseUrl}/auth/login";  // Replace with your backend UR
  // Login function that interacts with the backend
  Future<void> _login() async {
    bool hasError = false;

    // Password Validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        errorPassword = "الرجاء إدخال كلمة المرور";
        colorPassword = true;
      });
      hasError = true; // Mark an error, but don't return yet
    } else {
      setState(() {
        errorPassword = null;
        colorPassword = false;
      });
    }

    // Email Validation
    if (_emailController.text.isEmpty) {
      setState(() {
        errorEmail = "الرجاء إدخال البريد الإلكتروني";
        colorEmail = true;
      });
      hasError = true; // Mark an error
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

    if (hasError) return;
    try {
      // Show loading spinner (optional)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      // Handle different HTTP response statuses
      if (response.statusCode == 200) {
        // If login is successful, parse the response
        final data = json.decode(response.body);
        final String token = data['token'];  // Assuming the response contains a JWT token
        await _saveToken(token);
        _finishDescription(context);
        // Store the token if needed (e.g., in shared_preferences)
        // Navigate to the home screen or another screen on successful login

      } else {
        // Handle invalid credentials or other errors
        final data = json.decode(response.body);
        setState(() {
          // Reset errors
          errorEmail = null;
          errorPassword = null;
          colorEmail = false;
          colorPassword = false;

          // Assign errors based on backend response
          if ((response.statusCode == 404)||(response.statusCode == 400)) {
            errorEmail = data['message'];
            colorEmail = true;
          }
          if (response.statusCode == 403) {
            errorPassword = data['message'];
            colorPassword = true;
          }
        });

      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

  }
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  Future<void> _finishDescription(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false); // Set first_time = false

    String? token = prefs.getString('auth_token');
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'] ?? '';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()), // Admin goes here
          );
          return;
        }
      } catch (e) {
        print('Token decode error: $e');
      }
    }

    // Default: go to HomePage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

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
                  top: 280,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'مرحبًا بعودتك ',
                      textAlign: TextAlign.center,
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
            const SizedBox(height: 70,child:Text(  'أدخل البريد الإلكتروني الخاص بك و كلمة المرور',textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),),),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25),

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
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Password Input
                      Directionality(
                        textDirection: TextDirection.rtl, // Enforce RTL
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              textAlign: TextAlign.right,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 25.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EmailVerificationScreen()), // Replace with your screen widget
                              );
                            },
                            child: Text(
                              'نسيت كلمة المرور ؟',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30.0),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF9844A),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25.0),

                      // Sign Up Link
                      Directionality(
                        textDirection: TextDirection.rtl, // Force RTL layout
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'لا تمتلك حسابًا بعد؟ ',
                              style: TextStyle(color: Colors.black45),
                            ),
                            GestureDetector(
                              onTap:() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpScreen()), // Replace with your screen widget
                                );
                              },
                              child: Text(
                                'إنشاء حساب جديد',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF277DA1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
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