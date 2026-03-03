import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'change_personal_info.dart';
import 'change_normal_account.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'help_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';
import '../AUTH/login.dart';

class SettingsScreen extends StatefulWidget {
  static const Color primaryColor = Color(0xFF277DA1);
  static const Color backgroundColor = Color(0xFFFFFFFB);
  static const Color tileColor = Colors.white;

  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("❌ Invalid Token: $e");
      return {};
    }
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || JwtDecoder.isExpired(token)) {
        setState(() {
          errorMessage = "الرمز مفقود أو منتهي الصلاحية";
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> payload = decodeToken(token);
      print("✅ Decoded JWT: $payload");

      setState(() {
        userData = {
          "lastname": payload["lastname"] ?? "غير متوفر",
          "firstname": payload["firstname"] ?? "غير متوفر",
          "email": payload["email"] ?? "غير متوفر",
          "phone": payload["phone"] ?? "غير متوفر",
          "role": payload["role"] ?? "غير متوفر",
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "حدث خطأ أثناء جلب البيانات";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SettingsScreen.backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: SettingsScreen.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'الإعدادات',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF277DA1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsItem(
              icon: Icons.person,
              title: '  تعديل المعلومات الشخصية',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      // Check if the role is 'عادي' (normal user)
                      final String userRole = userData?['role'] ?? ''; // Get the role from the userData map

                      return userRole == 'مستخدم عادي'  // Compare if the role is 'عادي'
                          ? const ChangeNormalAccount()  // Navigate to ChangeNormalAccount for normal users
                          : const ChangePersonalInfo();  // Otherwise, navigate to ChangePersonalInfo
                    },
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.lock,
              title: '  تغيير كلمة المرور',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.delete,
              title: '  حذف الحساب',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountScreen(),
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.help,
              title: '  المساعدة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.privacy_tip,
              title: '  سياسة الخصوصية',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.contact_mail,
              title: '  اتصل بنا',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),
            SettingsItem(
              icon: Icons.logout,
              title: '  تسجيل الخروج',
              onTap: () async {
                // ✅ Réinitialiser la valeur de 'first_time'
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('first_time', true);

                // ✅ Naviguer vers l'écran de connexion
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );

                Future.delayed(const Duration(milliseconds: 100), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: const Text(
                          'تم تسجيل الخروج بنجاح',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                });
              },
              color: SettingsScreen.primaryColor,
              backgroundColor: SettingsScreen.tileColor,
            ),

          ],
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color color;
  final Color backgroundColor;

  static const Color borderColor = Color(0xFFB9D3E1);
  static const Color hoverColor = Color(0xFFF7FDFF);
  static const Color splashColor = Color(0xFFE9F1F5);

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          hoverColor: hoverColor,
          splashColor: splashColor,
          highlightColor: splashColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                ),
              ),
              trailing: Transform.translate(
                offset: const Offset(-8, 0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
