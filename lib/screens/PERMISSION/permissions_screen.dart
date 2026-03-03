import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

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
                  // Centered title
                  const Center(
                    child: Text(
                      'الصلاحيات المطلوبة',
                      style: TextStyle(
                        color: Color(0xFF277DA1),
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),

                  // Flipped back arrow on the left
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "من أجل تقديم تجربة سلسة وآمنة وسريعة، يتطلب تطبيق 'رفيق الطريق' منح الصلاحيات التالية:",
                style: TextStyle(
                  fontSize: 17,
                  height: 1.8,
                ),
                textAlign: TextAlign.right, // Align text to the right
              ),
              const SizedBox(height: 24),
              const PermissionCard(
                title: "الموقع الجغرافي (GPS)",
                icon: Icons.location_on_outlined,
                description:
                "نطلب صلاحية الوصول إلى الموقع الجغرافي من أجل تحديد مكانك بدقة. هذا يساعدنا على توجيهك بشكل أفضل وعرض الخدمات القريبة منك مثل خدمات السحب أو الميكانيكي. كما يتم استخدام هذه الصلاحية في حالات الطوارئ والإبلاغ عن الحوادث لتقديم أسرع استجابة ممكنة.",
              ),
              const SizedBox(height: 12),
              const PermissionCard(
                title: "الكاميرا",
                icon: Icons.photo_camera_outlined,
                description:
                "نحتاج إلى صلاحية استخدام الكاميرا لتمكينك من التقاط صور مباشرة عند الإبلاغ عن حادث مروري، مما يساعد فرق الدعم في توثيق الحالة بشكل أفضل، وتوصيل المعلومات بشكل أدق لمزودي الخدمات أو الجهات المختصة.",
              ),
              const SizedBox(height: 12),
              const PermissionCard(
                title: "الهاتف",
                icon: Icons.phone_outlined,
                description:
                "نستخدم صلاحية الهاتف لإجراء المكالمات المباشرة مع مزودي الخدمات (الميكانيكيين، شاحنات السحب وغيرها). كما تتيح لك التواصل معنا مباشرة لطلب الدعم الخاص بك في أي وقت تحتاج إلى مساعدة فورية أثناء التنقل.",
              ),
              const SizedBox(height: 12),
              const PermissionCard(
                title: "الخصوصية والأمان",
                icon: Icons.lock_outline,
                description:
                "نحن نحرص على حماية خصوصيتك بشكل كامل. يتم استخدام هذه الصلاحيات فقط لتنفيذ الميزات المتعلقة بالتطبيق، ولا يتم جمع أو مشاركة أي معلومات شخصية دون موافقتك المسبقة.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const PermissionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDFF),
        border: Border.all(color: const Color(0xFFB9D3E1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF277DA1)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF277DA1),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}
