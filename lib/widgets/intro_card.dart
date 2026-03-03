import 'package:flutter/material.dart';
import '../screens/QUIZ/intro_pages.dart';

class IntroCard extends StatelessWidget {
  final IntroPageModel page;
  final int index;
  final bool isLast;
  final VoidCallback? onNext;
  final int currentPageIndex;

  const IntroCard({
    super.key,
    required this.page,
    required this.index,
    required this.isLast,
    required this.onNext,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF277DA1),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Image
                    Image.asset(
                      page.imagePath,
                      width: constraints.maxWidth * 0.5,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 30),

                    // Description
                    Text(
                      page.descriptionText,
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),

              // Pagination Dots


              // Final Button

            ],
          ),
        );
      },
    );
  }
}
