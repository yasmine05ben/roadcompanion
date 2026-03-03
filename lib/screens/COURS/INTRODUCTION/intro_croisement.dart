import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/CROISEMENT.dart';
class IntroductionScreencroisement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "المقاطعة",
        imagePath: "assets/croisement.png",
        textColor: Color(0xFFC52C38),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 327,
              child: Text.rich( textDirection:TextDirection.rtl,
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'في هذا الباب سوف تتمكن من التعرف على كيفية التصرف عند التعرض لإحدى الحالات التالية :              ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '- ',
                      style: TextStyle(
                        color: Color(0xFFC52C38),
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'مقاطعة بطرق بها حواجز               ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '- ',
                      style: TextStyle(
                        color: Color(0xFFC52C38),
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'مقاطعة بمعبد ضيق              ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '-',
                      style: TextStyle(
                        color: Color(0xFFC52C38),
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: ' مقاطعة صعبة بطريق جبلي .              السؤال المطروح : ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'من يمر أولا ؟\n\n',
                      style: TextStyle(
                        color: Color(0xFFC52C38),
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'للإجابة عن ذلك يجب التّعرف على القواعد الواجب تطبيقها.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          SizedBox(height: 40),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CroisementScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade200,
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