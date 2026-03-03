import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      'سياسة الخصوصية',
                      style: TextStyle(
                        color: Color(0xFF277DA1),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
            children: const [
              Text(
                'توضح هذه السياسة كيف يقوم تطبيق "رفيق الطريق"، المطوّر لصالح الأكاديمية الوطنية للسلامة والأمن على الطرقات، بجمع المعلومات الشخصية واستخدامها وحمايتها.\n خصوصيتك مهمة بالنسبة لنا، ونحن ملتزمون بحماية بياناتك وفقًا للقوانين المعمول بها في مجال حماية البيانات.',
                style: TextStyle(
                  fontSize: 17,
                  height: 1.8,
                ),
                textAlign: TextAlign.right, // Align text to the right
              ),
              SizedBox(height: 22),

              PrivacySection(
                title: '1. المعلومات التي نقوم بجمعها',
                content:
                'أ. المعلومات الشخصية:\nقد نقوم بجمع اسمك، رقم هاتفك، عنوانك، بريدك الإلكتروني، ومعلوماتك المهنية.\n\n'
                    'ب. بيانات الموقع الجغرافي:\nنجمع بيانات GPS دقيقة لتفعيل الملاحة، تسهيل التبليغ عن الحوادث، وعرض مقدّمي الخدمات القريبين. يمكنك إيقاف الموقع من إعدادات الجهاز.\n\n'
                    'ج. بيانات الاستخدام والتشخيص:\nتشمل تفاعلك مع التطبيق وسجلات الأعطال لتحسين الأداء.\n\n'
                    'د. البيانات متعددة الوسائط:\nيتم تخزين الصور المرفوعة مؤقتًا وتُستخدم فقط لإدارة الحوادث.',
              ),

              SizedBox(height: 12),
              PrivacySection(
                title: '2. كيفية استخدام بياناتك',
                content:
                'يتم استخدام بياناتك لتقديم خدمات التطبيق، تنفيذ الطلبات، تحسين التثقيف المروري، وتعزيز أمان التطبيق.',
              ),

              SizedBox(height: 12),
              PrivacySection(
                title: '3. مشاركة البيانات والكشف عنها',
                content:
                'نحن لا نبيع أو نؤجر معلوماتك الشخصية. نشارك البيانات فقط مع شركاء موثوقين، الجهات القانونية عند الحاجة، ومزودي التحليل باستخدام بيانات مجهولة.',
              ),

              SizedBox(height: 12),
              PrivacySection(
                title: '5. حقوقك كمستخدم',
                content:
                'لك الحق في الوصول، تعديل أو حذف بياناتك. ويمكنك سحب موافقتك على تتبع الموقع في أي وقت والتواصل معنا لأي استفسار.',
              ),

              SizedBox(height: 12),
              PrivacySection(
                title: '6. خصوصية الأطفال',
                content:
                'تطبيق "رفيق الطريق" غير موجّه للأطفال دون سن 13 عامًا. ولا نجمع بيانات من القُصّر عمدًا.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacySection extends StatelessWidget {
  final String title;
  final String content;

  const PrivacySection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDFF),
        border: Border.all(color: Color(0xFFB9D3E1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, // No bullet points before the title
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF277DA1),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}
