import 'package:flutter/material.dart';
import 'contact_us_screen.dart';
import '../PERMISSION/permissions_screen.dart';
import 'pdf_viewer_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FAQItem> faqItems = [
      FAQItem(
        question: "كيف أستخدم التطبيق لأول مرة؟",
        answer: "ابدأ بتحديد موقعك والسماح للتطبيق بالوصول إلى الموقع الجغرافي. ثم انتقل إلى قسم 'بداية الاستخدام' لاستعراض الخصائص الأساسية مثل القوانين المرورية،المساعدة الآلية، الملاحة والإبلاغ عن الحوادث.",
      ),
      FAQItem(
        question: "كيف أطلب خدمة سحب أو ميكانيكي؟",
        answer: "انتقل إلى قسم 'المساعدة الآلية'، ثم اختر نوع الخدمة المطلوبة (سحب، ميكانيكي، أو قطع غيار). سيقوم التطبيق بتحديد موقعك والبحث عن أقرب مزود خدمة.",
      ),
      FAQItem(
        question: "هل بياناتي الشخصية آمنة؟",
        answer: "نعم، نحترم خصوصيتك ونستخدم تقنيات تشفير متقدمة لحماية بياناتك. ولا تتم مشاركة معلوماتك إلا في الحالات الضرورية لتقديم الخدمة المطلوبة.",
      ),
      FAQItem(
        question: "لماذا لا يظهر موقعي بشكل صحيح؟",
        answer: "تأكد من تفعيل خدمات الموقع ومنح التطبيق الصلاحيات اللازمة. إذا استمرت المشكلة، أعد تشغيل الجهاز أو تحقق من اتصال الإنترنت.",
      ),
      FAQItem(
        question: "كيف يمكنني الإبلاغ عن حادث مروري؟",
        answer: "اذهب إلى قسم 'نظام التوجيه الذّكي للمسارات'، ثم اختر نوع الحادث. يمكنك (اختياريًا) التقاط صورة وإضافة تعليق، ثم اضغط على زر 'الإبلاغ' لمشاركة البلاغ مع المستخدمين والجهات المختصة.",
      ),
      FAQItem(
        question: "هل يمكنني مراجعة قوانين المرور حسب الفئة؟",
        answer: "نعم، يمكنك تصفح القوانين مصنفة حسب الفئات مثل: إشارات الطريق، الأولويات، والعقوبات، وذلك من خلال قسم 'قوانين المرور'.",
      ),
      FAQItem(
        question: "كيف أستعد لاجتياز امتحان قانون المرور؟",
        answer: "استخدم قسم 'اختبار قواعد المرور' لإجراء اختبارات تدريبية مع تصحيح تلقائي وشروحات للأسئلة.",
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFB),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'قسم المساعدة',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF277DA1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF277DA1),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  'مرحباً، كيف يمكننا مساعدتك؟',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF277DA1),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 132,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  reverse: false,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PDFViewerScreen()),
                        );
                      },
                      child: const HelpOption(icon: Icons.rocket_launch, label: "بداية الاستخدام"),
                    ),

                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PermissionsScreen()),
                        );
                      },
                      child: const HelpOption(icon: Icons.lock, label: "الصلاحيات المطلوبة"),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ),
                        );
                      },
                      child: const HelpOption(icon: Icons.contact_support, label: "اتصل بنا"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'أسئلة متكررة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF277DA1),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ...faqItems.map((item) => ExpandableQuestion(item: item)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const HelpOption({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 126,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDFF),
        border: Border.all(color: const Color(0xFFB9D3E1)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF277DA1), size: 50),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class ExpandableQuestion extends StatefulWidget {
  final FAQItem item;

  const ExpandableQuestion({super.key, required this.item});

  @override
  State<ExpandableQuestion> createState() => _ExpandableQuestionState();
}

class _ExpandableQuestionState extends State<ExpandableQuestion> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: expanded ? const Color(0xFFE9F1F5) : const Color(0xFFFFFFFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9D3E1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.item.question,
            style: const TextStyle(fontSize: 16),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          trailing: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: Color(0xFFB9D3E1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF277DA1),
                size: 20,
              ),
            ),
          ),
          onExpansionChanged: (val) {
            setState(() {
              expanded = val;
            });
          },
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.item.answer,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
