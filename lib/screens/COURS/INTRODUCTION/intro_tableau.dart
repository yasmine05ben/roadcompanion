import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/TABLEAU.dart';
class IntroductionScreentableau extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "لوحة القيادة",
        imagePath: "assets/tableau.png",
        textColor:  Color(0xFFC52C38),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 313,
              height: 301,
              child: Text(
                'يهدف هذا الباب إلى التعريف بقواعد الأولوية وذلك:\n\n -بمفترق الطرقات ذات الاتجاه الدوراني.\n\n -بالمفترقات المجهزة بأضواء.\n\n - بالمفترقات بعلامات أو بدون علامات.\n \n',
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => TableauScreen()));
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