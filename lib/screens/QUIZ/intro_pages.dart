import 'package:flutter/material.dart';
import '../../widgets/intro_card.dart';
import 'tentative.dart';

class IntroPageModel {
  final String title;
  final String descriptionText;
  final String imagePath;

  IntroPageModel({
    required this.title,
    required this.descriptionText,
    required this.imagePath,
  });
}

class IntroPages extends StatefulWidget {
  @override
  _IntroPagesState createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  final List<IntroPageModel> pages = [
    IntroPageModel(
      title: 'مرحباً بك في اختبار قوانين المرور',
      descriptionText: 'هل أنت جاهز لاختبار معرفتك بقواعد الطريق؟ ',
      imagePath: 'assets/img_5.png',
    ),
    IntroPageModel(
      title: 'شرح سريع عن الاختبار',
      imagePath: 'assets/timer2.png',
      descriptionText:
      ' ● يتكون الاختبار من 40 سؤالًا حول قوانين المرور ⏳ \n ● لكل سؤال 40 ثانية فقط للإجابة لذا ركّز جيدًا!',
    ),
    IntroPageModel(
      title: 'طريقة الإختبار',
      imagePath: 'assets/img_287.png',
      descriptionText:
      'أنواع الأسئلة:\n ● سؤال مع 3 اقتراحات. \n ● سؤال مع 3 اقتراحات وصورة. \n ● سؤال "نعم أو لا" مع صورة.',
    ),
    IntroPageModel(
      title: 'ارشادات لاجتياز الاختبار',
      imagePath: 'assets/img_288.png',
      descriptionText:
      ' ● اقرأ الأسئلة بعناية قبل الإجابة.\n ● حاول اختيار الإجابة الصحيحة في أسرع وقت قبل فوات الأوان.\n ● عند انتهاء الوقت، سيتم الانتقال تلقائيًا إلى السؤال التالي.',
    ),
  ];

  int currentPageIndex = 0;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return IntroCard(
                page: pages[index],
                index: index,
                currentPageIndex: currentPageIndex,
                isLast: index == pages.length - 1,
                onNext: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PastAttemptsScreen()),
                  );
                },
              );
            },
          ),

          // Dot indicators
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                bool isActive = currentPageIndex == index;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Show "هيا نبدأ!" only on last page
          if (currentPageIndex == pages.length - 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 200, // 🔸 Adjust this value to make it smaller or larger
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PastAttemptsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("هيا نبدأ!"),
                  ),
                ),
              ),
            )

        ],
      ),
    );
  }
}
