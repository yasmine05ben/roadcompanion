import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/MARQUAGE.dart';
class IntroductionScreenmarquage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "رسوم الطّريق",
        imagePath: "assets/dessin.png",
        textColor: Color(0xFFC4931D),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          SizedBox(
            width: 327,
            child: SizedBox(
              width: 313,
              height: 550,
              child: Text(
                'الهدف من هذا الباب هو:\n التعرف على مختلف أنواع رسوم الطريق. \n فهي تنظم حركة المرور و تساعد على  الاستعمال السليم للطريق مثل بقية الإشارات الضوئية والعمودية ويفرض وجودها على مستعملي الطريق التزامات معينة تحقيقا للسلامة المرورية. \n\nتستعمل خاصة للإشارة إلى :\n\n - مختلف أجزاء الطريق .\n\n- مسالك السير المراد إتباعها .\n\n- المسالك الخاصة ببعض مستعملي الطريق.\n\n ترسم الإشارات السطحية على المعبد باللون الأبيض ويستعمل في بعض الأحيان اللون الأصفر، أما حافة الرصيف فتدهن عادة باللون الأبيض أو الأحمر و الأبيض أو الأصفر والأبيض.',
                textAlign: TextAlign.right,textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ),
          SizedBox(height: 30),
          Center(child:   ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MarquageScreen()));
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