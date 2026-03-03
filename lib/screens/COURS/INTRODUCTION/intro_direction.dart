import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/DIRECTION.dart';
class IntroductionScreendirection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "تغيير الاتجاه بالمفترقات",
        imagePath: "assets/direction.png",
        textColor:  Color(0xFFC52C38),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: Text(
              'الهدف من هذا الباب:\n\nهو معرفة الاحتياطات الواجب اتخاذها قبل لانعطاف إلى اليمين أو الى اليسار لسلك طريق أخرى أو للدخول إلى ملك مجاور .',
              textAlign: TextAlign.right,textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w300,
              ),
            )
          ),
          SizedBox(height: 70),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DirectionScreen()));
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