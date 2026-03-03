import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/background_screen.dart';
import 'homescreen.dart';
import '../ADMIN/admin_dashboard.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _checkFirstTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      _animation = Tween<double>(begin: -100, end: screenWidth + 100).animate(_controller)
        ..addListener(() => setState(() {}));
      _controller.repeat();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    await Future.delayed(Duration(seconds: 3));

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BackgroundScreen()),
      );
    } else {
      String? token = prefs.getString('auth_token');
      if (token != null) {
        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          String role = decodedToken['role'] ?? '';

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
            return;
          }
        } catch (e) {
          print('Token decode error: $e');
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img_8.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),

// ---
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'رفيق',
                        style: TextStyle(
                          color: const Color(0xFF277DA1),
                          fontSize: 40,
                          fontFamily: 'GraphicSchool',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: ' الطريق',
                        style: TextStyle(
                          color: const Color(0xFF292729),
                          fontSize: 40,
                          fontFamily: 'GraphicSchool',
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'تنقل بثقة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF292729),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 70, // Adjust this to position the entire road section
            left: 0,
            right: 0,
            child: SizedBox( // Use SizedBox to contain both road and car
              height: 120, // Enough space for car and road
              child: Stack(
                clipBehavior: Clip.none, // Allows car to extend beyond container
                children: [
                  // Road Container
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Top horizontal blue line
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Color(0xff277DA1),
                            ),
                          ),
                          // Bottom horizontal blue line
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Color(0xff277DA1),
                            ),
                          ),
                          // Dashed center line (black)
                          Center(
                            child: Container(
                              height: 2,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: DashedLinePainter(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated Car - positioned above the road
                  if (_initialized)
                    Positioned(
                      left: _animation.value,
                      bottom: 20, // Adjust to position car relative to road
                      child: Image.asset(
                        'assets/img_290.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 40;
    const dashSpace = 20;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}