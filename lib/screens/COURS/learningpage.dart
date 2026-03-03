import 'package:flutter/material.dart';
import 'INTRODUCTION/intro_arret_stat.dart';
import 'INTRODUCTION/intro_depassement.dart';
import 'INTRODUCTION/intro_direction.dart';
import 'INTRODUCTION/intro_eclairage.dart';
import 'INTRODUCTION/intro_marquage.dart';
import 'INTRODUCTION/intro_regle_priorite.dart';
import 'INTRODUCTION/intro_signalisation.dart';
import 'INTRODUCTION/intro_tableau.dart';
import 'INTRODUCTION/pan.dart';
import 'INTRODUCTION/intro_croisement.dart';
import 'INTRODUCTION/intro_vitesse.dart';
import 'INTRODUCTION/intro_autoroute.dart';

class learningpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final List<Map<String, dynamic>> panneaux = [
      {"name": "ّقانون الطرقات وعلامات الطريقً", "dx": 0.1, "dy": 0.026, "image": "assets/pan1.png", "color": Color(0xFFC4931D), "textDx": 0.19, "textDy": -0.005,"page": () => IntroductionScreen()},
      {"name": "المقاطعة", "dx": 0.55, "dy": 0.1, "image": "assets/pan2.png", "color": Color(0xFFC52C38), "textDx": -0.15, "textDy": -0.0015,"page": () =>IntroductionScreencroisement()},
      {"name": "الطريق السيارة", "dx": 0.25, "dy": 0.168, "image": "assets/pan3.png", "color": Color(0xFF00D533), "textDx": 0.16, "textDy": -0.005,"page": () =>IntroductionScreenautoroute()},
      {"name": "السرعة", "dx": 0.55, "dy": 0.24, "image": "assets/pan4.png", "color": Color(0xFFF9844A), "textDx": -0.12, "textDy": -0.005,"page": () =>IntroductionScreenvitesse()},
      {"name": "المجازوة", "dx": 0.25, "dy": 0.31, "image": "assets/pan5.png", "color": Color(0xFF407BFF), "textDx": 0.15, "textDy": -0.005,"page": () =>IntroductionScreendepassement()},
      {"name": "الأولوية", "dx": 0.55, "dy": 0.38, "image": "assets/pan6.png", "color": Color(0xFFC4931D), "textDx": -0.13, "textDy": -0.005,"page": () =>IntroductionScreenregle_prio()},
      {"name": "تغيير الاتجاه بالمفترقات", "dx": 0.25, "dy": 0.454, "image": "assets/pan7.png", "color": Color(0xFFC52C38), "textDx": 0.12, "textDy": -0.0059,"page": () =>IntroductionScreendirection()},
      {"name": "الإشارات الضوئية", "dx": 0.55, "dy": 0.526, "image": "assets/pan8.png", "color": Color(0xFF00D533), "textDx": -0.26, "textDy": -0.005,"page": () =>IntroductionScreensignalisation()},
      {"name": "الوقوف والتّوقّف", "dx": 0.25, "dy": 0.595, "image": "assets/pan9.png", "color": Color(0xFFF9844A), "textDx": 0.14, "textDy": -0.005,"page": () =>IntroductionScreenarret_stat()},
      {"name": "إضاءة العربات واشاراتها", "dx": 0.55, "dy": 0.665, "image": "assets/pan10.png", "color": Color(0xFF407BFF), "textDx": -0.36, "textDy": -0.005,"page": () =>IntroductionScreeneclairage()},
      {"name": "رسوم الطّريق", "dx": 0.25, "dy": 0.735, "image": "assets/pan11.png", "color": Color(0xFFC4931D), "textDx": 0.15, "textDy": -0.007,"page": () =>IntroductionScreenmarquage()},
      {"name": "لوحة القيادة", "dx": 0.55, "dy": 0.805, "image": "assets/pan12.png", "color":Color(0xFFC52C38), "textDx": -0.18, "textDy": -0.005,"page": () =>IntroductionScreentableau()},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("تعلم قواعد المرور", style: TextStyle(color: Color(0xFF277DA1))),
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 4, // ✅ Shadow below AppBar
        shadowColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: Image.asset(
            'assets/img_20.png', // Replace with your arrow image path
            width: 24, // Adjust size as needed
            height: 24,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigates back when pressed
          },
        ),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Image.asset(
                'assets/img_1444.png',
                width: screenWidth,
                height: screenHeight * 2.25,
                fit: BoxFit.contain,
              ),
              for (var panneau in panneaux) ...[
                // Positioning the text dynamically
                Positioned(
                  left: (panneau["dx"] + panneau["textDx"]) * screenWidth,
                  top: (panneau["dy"] + panneau["textDy"]) * screenHeight * 2.3,
                  child: Text(
                    panneau["name"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: panneau["color"], // Dynamic color
                      shadows: [
                        Shadow(
                          blurRadius: 3.0, // How much the shadow spreads
                          color: Colors.black.withOpacity(0.2), // Shadow color
                          offset: Offset(0, 2), // Moves the shadow to the bottom-right
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioning the panneau dynamically
                Positioned(
                  left: panneau["dx"] * screenWidth,
                  top: panneau["dy"] * screenHeight * 2.3,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => panneau["page"](),
                        ),
                      );
                    },
                    child: Image.asset(
                      panneau["image"],
                      width: screenWidth * 0.15,
                      height: screenWidth * 0.18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


