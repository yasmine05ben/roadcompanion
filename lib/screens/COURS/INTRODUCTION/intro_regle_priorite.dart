import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/REGLE_PRIO.dart';
class IntroductionScreenregle_prio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "الأولوية",
        imagePath: "assets/prio.png",
        textColor:Color(0xFFC4931D),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 327,
              child:Text(
                'يهدف هذا الباب  إلى التعريف بقواعد الأولوية  وذلك :\n   - بالمفترقات بعلامات أو بدون علامات.   -بالمفترقات المجهزة بأضواء .   -بمفترق الطرقات ذات الاتجاه الدوراني.\n',
                textAlign: TextAlign.right,textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              )
            ),
          ),
          SizedBox(height: 90),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReglePrioScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade200,
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