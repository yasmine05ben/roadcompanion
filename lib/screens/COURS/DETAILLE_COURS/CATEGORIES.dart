import 'package:flutter/material.dart';
import '/widgets/DETAILS.dart';
import 'indications.dart';
import 'obligations.dart';
import 'INTROSTOP.dart'; // Example page
import 'priorities.dart'; // Another example page
import 'temporary.dart';
import 'INTROPROHB.dart';
import 'INTRODANGER.dart';
class  assistancepageee extends StatelessWidget {
  assistancepageee({super.key});

  final List<Map<String, dynamic>> panneaux = [
    {
      "title": "علامات الوقوف والتوقف",
      "image": "assets/CAT1.png",
      "color": Colors.blue,
      "page": IntroductionScreenSTOP(), // Navigates to STOP page
    },
    {
      "title": "علامات المنع و انتهاء المنع",
      "image": "assets/CAT2.png",
      "color": Color(0xFFEC1B36),
      "page": IntroductionScreenPROB(), // Navigates to PRIORITY page
    },
    {
      "title": "علامات الخطر",
      "image": "assets/CAT3.png",
      "color": Color(0xFFC52C38),
      "page": IntroductionScreenDANGER(),
    },
    {
      "title": "علامات الأولوية",
      "image": "assets/CAT4.png",
      "color": Color(0xFFF9C74F),
      "page": IntroductionScreenprt(),
    },
    {
      "title": "علامات الجبر و انتهاء الجبر",
      "image": "assets/CAT5.png",
      "color": Color(0xFF1A85C4),
      "page": IntroductionScreenoblg(),
    },
    {
      "title": "العلامات الوقتية",
      "image": "assets/CAT6.png",
      "color": Color(0xFFF9844A),
      "page": IntroductionScreentmp(),
    },
    {
      "title": "علامات الإرشاد",
      "image": "assets/CAT7.png",
      "color": Color(0xFFA1A1A1),
      "page": IntroductionScreenindication(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "قانون الطرقات وعلامات الطريق",
        imagePath: "assets/img_19.png",
        textColor: Color(0xFFC4931D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 40), // Space at the top
            Expanded(
              child: ListView.separated(
                itemCount: panneaux.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (panneaux[index]["page"] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => panneaux[index]["page"], // Navigate to assigned page
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        width: 350,
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFA1A1A1), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                panneaux[index]["title"]!,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 2,
                              height: 67,
                              color: panneaux[index]["color"],
                            ),
                            const SizedBox(width: 10),
                            Image.asset(
                              panneaux[index]["image"]!,
                              width: 50,
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
