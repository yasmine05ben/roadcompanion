import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/DEPASSEMENT.dart';
class IntroductionScreendepassement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "المجازوة",
        imagePath: "assets/depassement.png",
        textColor: Color(0xFF407BFF),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
      SizedBox(
        width: 313,
        height: 469,
        child: Text(
            'كما هو الشأن عند الاقتراب من مفترق طرقات ، يجب على السائق مضاعفة الانتباه والحذر عند القيام بعملية المجاوزة.\n\nفالمجاوزة التي تشكل خطرا على الجولان يمكن أن تؤدي إلى حادث مرور لذلك يجب اتخاذ الاحتياطات اللازمة عند الشروع في هذه المناورة لإنهائها بكل أمان .\n\nوسوف تتعرف من خلال هذا الباب على كيفية القيام بعملية المجاوزة والحالات التي تمنع فيها المجاوزة.',
            textAlign: TextAlign.right,textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w300,
            ),
          ),),
          SizedBox(height: 60),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DepassementScreen()));
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