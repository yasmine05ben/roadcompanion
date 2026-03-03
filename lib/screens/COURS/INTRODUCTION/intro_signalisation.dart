import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/SIGNALISATION.dart';
class IntroductionScreensignalisation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "الإشارات الضوئية",
        imagePath: "assets/feu.png",
        textColor: Color(0xFF00D533),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: Text(
              'تستعمل الإشارات الضوئية بهدف ضمان السلامة المرورية وتحسين سيولة الجولان.\n\nيمكن أن تأخذ الأضواء شكلين: أضواء دائرية أو في شكل أسهم.\n\nتنظم الأضواء الثلاثية حركة المرور بالمفترقات. فيما تنظم الأضواء الثنائية حركة المرور بمحطات الاستخلاص وبممرات المترجلين وبتقاطع الطرقات\nمع السكة الحديدية.',
              textAlign: TextAlign.right,textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            )
          ),
          SizedBox(height: 40),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignalisationScreen()));
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