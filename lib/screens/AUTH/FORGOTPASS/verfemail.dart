import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'verefcode.dart';
import '/config.dart';

class EmailVerificationScreen extends StatefulWidget {
@override
_EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool colorEmail = false;
      String? errorEmail;
  final String _apiUrl = "${Config.baseUrl}/auth/forgot-password";
  Future<void> _checkEmail() async {
    // Email Validation
    if (_emailController.text.isEmpty) {
      setState(() {
        errorEmail = "الرجاء إدخال البريد الإلكتروني";
        colorEmail = true;

      });
      return;// Mark an error
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      setState(() {
        errorEmail = "الرجاء إدخال بريد إلكتروني صالح";
        colorEmail = true;
      });
      return;
    } else {
      setState(() {
        errorEmail = null;
        colorEmail = false;
      });
    }


    try {
      // Show loading spinner (optional)
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
        }),
      );

      // Handle different HTTP response statuses
      if (response.statusCode == 404) {
        // Handle invalid credentials or other errors
        final data = json.decode(response.body);
        setState(() {
          // Reset errors
          errorEmail = data['message'];
          colorEmail = true;
        });

      } else  { // Assuming the response contains a JWT token

      // Store the token if needed (e.g., in shared_preferences)
      // Navigate to the home screen or another screen on successful login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CodeVerificationScreen(email: _emailController.text.trim())),);// Replace with your HomeScreen

      }

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}')),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView( // Wrap Column to prevent overflow
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 70), // Adjusted spacing
                    Text(
                      "لنجد حسابك !",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF277DA1),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Blue Circle with Image
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD7E6EC),
                      ),
                      child: Center(
                        child: Image.asset(colorEmail ? 'assets/Vector2.png' : 'assets/Vector.png', // Change image based on colorEmail
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Text Below the Circle
                    Text(
                      "أدخل بريدك الإلكتروني لاستعادة كلمة المرور",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 50),

                    // Email Input Field
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




                    SizedBox(height: 80), // Reduced height to avoid overflow

                    // Send Code Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _checkEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF9844A),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "إرسال الرمز",
                          style: TextStyle(fontSize: 22, color: Colors.white,fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Extra padding for bottom spacing
                  ],
                ),
              ),
            ),

            // Back Button at the Top Left
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
                    color: Colors.white, // Background color
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2), // Shadow effect
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Wrap content
                    children: [
                      Image.asset(
                        'assets/arrow-left.png', // Replace with your image asset
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 8), // Space between image and text
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
