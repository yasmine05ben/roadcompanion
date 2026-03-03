import 'package:flutter/material.dart';
import 'assurance_question_page.dart';
import 'assurance_question1_page.dart';
import 'assurance_question2_page.dart';
class CircularSlidingChoices extends StatefulWidget {
  @override
  _CircularSlidingChoicesState createState() => _CircularSlidingChoicesState();
}

class _CircularSlidingChoicesState extends State<CircularSlidingChoices> {
  int currentIndex = 0;
  final List<String> choices = [
    "assets/img_283.png", // Mechanics
    "assets/img_284.png", // Depannage
    "assets/img_285.png"  // Spare
  ];

  void nextSlide() {
    setState(() {
      currentIndex = (currentIndex + 1) % choices.length;
    });
  }

  void previousSlide() {
    setState(() {
      currentIndex = (currentIndex - 1 + choices.length) % choices.length;
    });
  }

  void validateChoice() {
    switch (currentIndex) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  AssuranceQuestionPage2()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  AssuranceQuestionPage1()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AssuranceQuestionPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "المساعدة الآلية",
          style: TextStyle(color: Color(0xFF277DA1), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF277DA1)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "كيف يمكننا مساعدتك اليوم؟",
            style: TextStyle(
              color: Color(0xFF277DA1),
              fontSize: 24,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Moving decorative dots
                AnimatedPositioned(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  top: 90 + (currentIndex == 0 ? 0 : currentIndex == 1 ? -40 : 100),
                  left: screenWidth * (0.3 + (currentIndex == 0 ? 0.05 : currentIndex == 1 ? 0.25 : 0.55)),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9844A), // Orange
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  top: 60 + (currentIndex == 0 ? 0 : currentIndex == 1 ? 130 : 20),
                  right: screenWidth * (0.4 + (currentIndex == 0 ? 0.05 : currentIndex == 1 ? -0.25 : 0.2)),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9C74F), // Yellow
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  top: 200 + (currentIndex == 0 ? 0 : currentIndex == 1 ? -100 : -150),
                  left: screenWidth * (0.80 + (currentIndex == 0 ? 0.05 : currentIndex == 1 ? -0.45 : -0.20)),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Color(0xFF79A2FF), // Blue
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Circular sliding choices
                ...List.generate(choices.length, (index) {
                  int position = (index - currentIndex + choices.length) % choices.length;
                  double scale = position == 0 ? 1.2 : 0.7;
                  double xOffset = position == 0 ? -15 : (position == 1 ? 140 : -110);
                  double yOffset = position == 0 ? 50 : -60;

                  return AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    left: screenWidth / 2 - 70 + xOffset,
                    top: 100 + yOffset,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width: 160 * scale,
                      height: 160 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        choices[index],
                        fit: BoxFit.contain,
                        width: 190,
                        height: 190,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            "حل مشكلتك بضغطة واحدة! \n اختر الخدمة التي تحتاجها ودعنا نهتم بالباقي!",
            style: TextStyle(fontSize: 19, color: Colors.black, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 42,
                decoration: ShapeDecoration(
                  color: Color(0xFFF9C74F),
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 24, color: Colors.black),
                  onPressed: previousSlide,
                ),
              ),
              SizedBox(width: 70),
              Row(
                children: List.generate(choices.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index ? Color(0xFFF9844A) : Color(0xFFD9D9D9),
                    ),
                  );
                }),
              ),
              SizedBox(width: 70),
              Container(
                width: 46,
                height: 42,
                decoration: ShapeDecoration(
                  color: Color(0xFFF9C74F),
                  shape: OvalBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, size: 24, color: Colors.black),
                  onPressed: nextSlide,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: validateChoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF9844A),
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: Text(
              "احصل على المساعدة",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
