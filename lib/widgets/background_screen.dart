import 'package:flutter/material.dart';
import 'package:raodsafety/widgets/pagecontent.dart';
import 'page_content.dart';
import 'pagecontent.dart';
class BackgroundScreen extends StatefulWidget {
  @override
  _BackgroundScreenState createState() => _BackgroundScreenState();
}

class _BackgroundScreenState extends State<BackgroundScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF277DA1), // Set the background color to #277DA1
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              PageContent2(screenWidth, 'assets/img.png', 'دليلك لتعلم قواعد المرور', 'ابحث وتصفح قوانين المرور ومختلف أقسامها : الاشارات،الأولويات . . .  '),
              PageContent2(screenWidth, 'assets/img_5.png', 'اختبر معلوماتك', 'قم باختبار معلوماتك حول قوانين المرور باجتياز اختبارات QCM دقيقة  بمعايير رسمية واحترافية.'),
              PageContent2(screenWidth, 'assets/img_3.png', 'تنقل بذكاء', 'أحصل عى توجيهات مباشرة أثناء سيرك وقيادتك، تعليمات صوتية وتنبيهات عن الحوادث والمخاطر التي يمكنها اعتراضك.'),
              PageContent2(screenWidth, 'assets/img_4.png', 'الإبلاغ والتنبيه!', 'بلّغ فورًا عن الحوادث أو المخاطر مع مشاركة الصّور والموقع.'),
              PageContent2(screenWidth, 'assets/img_6.png', 'أحصل على المساعدة سريعا!', 'تستطيع العثور على أقرب الميكانيكيين، الاتصال بشاحنة السّحب في حالة طوارئ وطلب قطع الغيار من أقرب نقطة بيع '),
              PageContent(screenWidth, 'assets/img_8.png', 'تنقّل بثقة', 'كن دائمًا مطّلعًا، مستعدًا، وآمنًا مع رفيقك المثالي في الطريق  '),
            ],
          ),

          // Page Indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => buildDot(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    bool isCurrent = _currentPage == index;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: isCurrent ? 16 : 8, // Dash width for active page
      height: 8, // Uniform height for all indicators
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Rounded corners for dash
      ),
    );
  }
}


