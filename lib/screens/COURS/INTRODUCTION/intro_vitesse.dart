import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/VITESSE.dart';
class IntroductionScreenvitesse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "السّرعة",
        imagePath: "assets/vitesse.png",
        textColor: Color(0xFFF9844A),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 313,
            height: 569,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: 'يجب على السائق أن يكون دائما يقظا ومتحكما في سرعة عربته ، كما يجب أن يعدل من سرعته حسب ما تقتضيه إشارات المرور وحالة الطريق والطقس وكثافة الجولان والعوارض المتوقعة  فالامتثال للعلامات المحددة للسرعة واختيار السرعة التي تتناسب مع حالة المعبد من شأنه المساهمة في الوقاية من حوادث الطرقات.\n\nو سوف تتعرف من خلال هذا الباب على كيفية احتساب:\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextSpan(
                    text: '\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '-',
                    style: TextStyle(
                      color: Color(0xFF277DA1),
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'مسافة زمن رد الفعل.\n',
                    style: TextStyle(
                      color: Color(0xFF277DA1),
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '-مسافة الوقوف.\n',
                    style: TextStyle(
                      color: Color(0xFF277DA1),
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '-مسافة الأمان.',
                    style: TextStyle(
                      color: Color(0xFF277DA1),
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.right,textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(height: 10),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VitesseScreen()));
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