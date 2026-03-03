import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/ECLAIRAGE.dart';
class IntroductionScreeneclairage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "إضاءة العربات واشاراتها",
        imagePath: "assets/voiture.png",
        textColor: Color(0xFF407BFF),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            height: 450,
            child: SizedBox(
              width: 313,
              height: 229,
              child: Text(
                'الهدف من هذا الباب هو:\n تمكينك من معرفة الأضواء القانونية التي يجب أن تجهز بها العربات وكيفية استعمالها حسب المكان والظروف.\n\nيجب على كل سائق في الليل وكلما اقتضت ظروف الرؤية نهارا أن يستعمل الأضواء المتعلقة بتجهيز وتهيئة العربات.',
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
          SizedBox(height: 10),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EclairageScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade200,
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