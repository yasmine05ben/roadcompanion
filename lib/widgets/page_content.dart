import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import '../screens/AUTH/login.dart'; // Import the login screen

class PageContent extends StatelessWidget {
  final double screenWidth;
  final String imagePath;
  final String title;
  final String description;

  PageContent(this.screenWidth, this.imagePath, this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return _buildPageWithLoginButton(
      context, // Pass context here
      screenWidth,
      imagePath,
      title,
      description,
    );
  }

  // 🔹 Function to build the page with a login button
  Widget _buildPageWithLoginButton(
      BuildContext context, // Accept context as a parameter
      double screenWidth,
      String imagePath,
      String title,
      String description,
      ) {
    return Stack(
      children: [
        // Background Shape with Image
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: ProsteThirdOrderBezierCurve(
              position: ClipPosition.bottom,
              list: [
                ThirdOrderBezierCurveSection(
                  p1: Offset(2, 900),
                  p2: Offset(0, 300),
                  p3: Offset(screenWidth, 550),
                  p4: Offset(screenWidth, 300),
                ),
              ],
            ),
            child: Container(
              height: 550,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 130),
                  Image.asset(
                    imagePath,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Title Text
        Positioned(
          top: 510,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Description Text
        Positioned(
          top: 580,
          left: 4,
          right: 4,
          child: Center(
            child: Text(
              description,textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // 🔹 Login Button
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to LoginScreen
                Navigator.push(
                  context, // Pass context correctly
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:const Color(0xFFB9D3E1) ,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'هيا ننطلق!',textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
