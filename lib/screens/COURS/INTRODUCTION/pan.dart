import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import '../DETAILLE_COURS/CATEGORIES.dart';

class IntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "قانون الطرقات وعلامات الطريق",
        imagePath: "assets/img_19.png",
        textColor: Color(0xFFC4931D),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 310,
                height: 347,
                child: Text(
                  'تمثل علامات الطريق رمزا دلاليا و قاعدة تواصل تمكن مستعملي الطريق من الجولان بكل سلامة .    و يرتكز هذا الرمز على 3 وظائف رئيسية :   1 - التنبيه لحالات الخطر  2- المنع و الجبر  أو الإلزام  3- إعلام و إرشاد مستعملي الطريق   و ستتمكن من خلال هذا  الباب من إدراك  معاني أشكال العلامات و ألوانها  لتستطيع بذالك التعرف   بيسر و بسرعة على مدلول  كل علامة .',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 120),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => assistancepageee()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade100,
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
              ),
            ),
            SizedBox(height: 40), // extra padding at bottom for better scroll feel
          ],
        ),
      ),
    );
  }
}
