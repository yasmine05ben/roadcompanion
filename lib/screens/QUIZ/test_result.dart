import 'package:flutter/material.dart';
import 'tentative.dart';
class TestResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const TestResultPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate which image to show based on score
    List<Map<String, dynamic>> ranges = [
      {"min": 0, "max": 7, "image": "assets/S1.png"},
      {"min": 8, "max": 14, "image": "assets/S2.png"},
      {"min": 15, "max": 20, "image": "assets/S3.png"},
      {"min": 21, "max": 26, "image": "assets/S4.png"},
      {"min": 27, "max": 33, "image": "assets/S5.png"},
      {"min": 34, "max": 40, "image": "assets/S6.png"},
    ];

    String imagePath = "assets/default.png";
    for (var range in ranges) {
      if (score >= range["min"] && score <= range["max"]) {
        imagePath = range["image"];
        break;
      }
    }

    // Show the dialog immediately when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red, size: 30),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => PastAttemptsScreen()),
                              (route) => false,
                        );
                      },


                    ),
                  ),
                  Text(
                    "النتيجة",
                    style: TextStyle(
                      color: const Color(0xFF277DA1),
                      fontSize: 25,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.asset(
                    imagePath,
                    height: 140,
                    width: 140,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: 60, color: Colors.red),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "$score / $totalQuestions",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "كل مجهود يستحق التقدير\n✨والأهم هو الاستمرار في التعلم والتطور!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      );
    });

    // Return an empty scaffold since we're showing a dialog immediately
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(),
    );
  }
}