import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/AUTOROUTE.dart';
class IntroductionScreenautoroute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "الطريق السيارة",
        imagePath: "assets/autoroute.png",
        textColor: Color(0xFF00D533),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 308,
              height: 235,
              child: Text(
                'تشمل الطرقات السيارة على ممرين منفصلين لحركة المرور، حيث يجب على السائقين اتباع قواعد خاصة عند الدخول إليها والخروج منها لضمان سلامة جميع مستعملي الطريق.\n',
                textAlign: TextAlign.right,textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ),
          SizedBox(height: 40),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => autorouteScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade200,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'هيا لنبدأ!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),)
        ],
      ),
    );
  }
}