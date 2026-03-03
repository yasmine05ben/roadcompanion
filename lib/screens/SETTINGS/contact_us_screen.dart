import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+213549429546');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'theroadcompanionapp@gmail.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchFacebook() async {
    final Uri fbUri = Uri.parse('https://www.facebook.com/NATSRS.PageOfficielle');
    if (await canLaunchUrl(fbUri)) {
      await launchUrl(fbUri, mode: LaunchMode.externalApplication);
    }
  }

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
                      'اتصل بنا',
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
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/contact_us_header.png',
                      width: 201,
                      height: 190,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تواصل معنا وشاركنا آرائك',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ContactItem(
                icon: Icons.phone,
                title: 'الهاتف المهني',
                subtitle: '+213549429546',
                onTap: _launchPhone,
              ),
              const SizedBox(height: 20),
              ContactItem(
                icon: Icons.email,
                title: 'البريد الإلكتروني',
                subtitle: 'theroadcompanionapp@gmail.com',
                onTap: _launchEmail,
              ),
              const SizedBox(height: 20),
              ContactItem(
                icon: Icons.facebook,
                title: 'حساب فيسبوك',
                subtitle: 'https://www.facebook.com/NATSRS.PageOfficielle',
                onTap: _launchFacebook,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ContactItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FDFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB9D3E1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF277DA1), size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF277DA1),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
