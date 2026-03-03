import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/ARRET_STAT.dart';
class IntroductionScreenarret_stat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "الوقوف والتّوقّف",
        imagePath: "assets/stop.png",
        textColor: Color(0xFFF9844A),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 313,
              height: 544,
              child: Text.rich(
                TextSpan(
                  children: [
                TextSpan(
                text: 'الهدف من هذا الباب :\n\n',
                style: TextStyle(
                color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: 'تمكينك من التمييز بين الوقوف والتوقف .\n',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: '\n',
              style: TextStyle(
              color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
            TextSpan(
              text: 'التعرف على الأماكن التي يمكنك الوقوف والتوقف بها : \n',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            ),
            TextSpan(
              text: 'داخل مواطن العمران وخارجها.\nفي طريق ذات اتجاهين أو ذات اتجاه واحد.\n',
            style: TextStyle(
            color: Colors.black,
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
            ),
          ),
          TextSpan(
            text: '\nو سوف تتعرف كذلك على الأماكن التي يحجر الوقوف والتوقف بها.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.right,textDirection: TextDirection.rtl,
    ),
    )
          ),
          SizedBox(height: 20),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArretStatScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade200,
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