import 'package:flutter/material.dart';
import 'assurance_list_page.dart';
import 'sparerqst.dart';

class AssuranceQuestionPage2 extends StatelessWidget {
  const AssuranceQuestionPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = const Color(0xFF277DA1);
    final Color secondaryColor = const Color(0xFF43AA8B);
    final Color accentColor = const Color(0xFFF94144);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: mainColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'التأمينات',
          style: TextStyle(
            color: Color(0xFF277DA1),
            fontSize: 23,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Icon(Icons.car_repair, size: 50, color: mainColor),
                  const SizedBox(height: 15),
                  const Text(
                    "مرحبًا بك في خدمة التأمينات!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF1F3C5C),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "يمكننا مساعدتك في حالات الأعطال أو الحوادث سواء كنت مؤمنًا أو لا. اختر الخيار المناسب لموقفك.",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Cairo',
                      color: Color(0xFF4B4B4B),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Benefits section


            // Main question card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              elevation: 6,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.car_crash_outlined, size: 50, color: mainColor),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "هل تمتلك تأمينًا ساريًا على سيارتك؟",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                        color: Color(0xFF1F3C5C),
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 30),

                    // Yes button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor, secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AssuranceListPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "نعم، لدي تأمين",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // No button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Normal2UserScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "لا، أحتاج إلى طلب خدمة",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Help section
            GestureDetector(
              onTap: () => _showHelpDialog(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mainColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.help_outline, color: Color(0xFF277DA1)),
                    SizedBox(width: 8),
                    Text(
                      "هل تحتاج إلى مساعدة؟",
                      style: TextStyle(
                        color: Color(0xFF277DA1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      avatar: Icon(icon, size: 20, color: color),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(4),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "مساعدة",
          style: TextStyle(
            color: Color(0xFF277DA1),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "إذا كنت تمتلك تأمينًا على سيارتك، يمكنك اختيار الخيار الأول لاستخدامه في تغطية تكاليف الخدمة.",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 15),
            Text(
              "إذا لم يكن لديك تأمين، يمكنك طلب الخدمة مباشرة وسنقوم بتقديم أفضل الحلول لك.",
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسنًا"),
          ),
        ],
      ),
    );
  }
}