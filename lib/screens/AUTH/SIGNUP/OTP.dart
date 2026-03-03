import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'FORM.dart';
import '/config.dart';
class OTPVerificationScreen extends StatefulWidget {
  final String email;

  OTPVerificationScreen({required this.email});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());

  final String _apiUrl =
      "${Config.baseUrl}/auth/verify";

  bool isError = false;
  String? errorMessage;

  Future<void> _verifyOTP() async {
    String enteredOTP = _controllers.map((c) => c.text).join();

    if (enteredOTP.length < 6) {
      setState(() {
        isError = true;
        errorMessage = "يرجى إدخال رمز التحقق المكون من 6 أرقام";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'code': enteredOTP,
        }),
      );

      if (response.statusCode == 400) {
        final data = json.decode(response.body);
        setState(() {
          isError = true;
          errorMessage = data['message'] ?? "رمز غير صحيح، حاول مرة أخرى";
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FormScreen(email:widget.email)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    }
  }

  Widget _buildOTPInputField(int index) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isError ? Colors.red : Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isError ? Colors.red : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            BorderSide(color: isError ? Colors.red : Color(0xFF277DA1), width: 2.0),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 70),
                    Text(
                      "تفقد رسائلك على Email",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF277DA1),
                      ),
                    ),

                    SizedBox(height: 15),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD7E6EC),
                      ),
                      child: Center(
                        child: Image.asset(
                          isError ? 'assets/img_13.png' : 'assets/img_12.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "من فضلك أدخل رمز التحقق المكون من 6 رموز الذي تلقيته على  ${widget.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "تحقق من spam إذا لم يصلك الرمز",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) => _buildOTPInputField(index)),
                    ),
                    if (isError && errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF9844A),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "تحقق",
                          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        for (var controller in _controllers) {
                          controller.clear();
                        }

                        try {
                          final response = await http.post(
                            Uri.parse("${Config.baseUrl}/auth/register"),
                            headers: {'Content-Type': 'application/json'},
                            body: json.encode({'email': widget.email}),
                          );

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("تم إرسال رمز OTP جديد إلى بريدك الإلكتروني")),
                            );
                          } else {
                            final data = json.decode(response.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(data['message'] ?? "حدث خطأ أثناء إرسال الرمز")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("خطأ في الاتصال: $e")),
                          );
                        }
                      },
                      child: Text(
                        "إرسال رمز جديد ",
                        style: TextStyle(fontSize: 18, color: Color(0xFF277DA1), fontWeight: FontWeight.w800),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
            // Back Button at the Top Left
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 28, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
