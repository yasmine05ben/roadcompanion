import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProfileScreen1 extends StatefulWidget {
  @override
  _UserProfileScreen1State createState() => _UserProfileScreen1State();
}

class _UserProfileScreen1State extends State<UserProfileScreen1> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  static const Color primaryColor = Color(0xFF277DA1);
  static const Color borderColor = Color(0xFFB9D3E1);
  static const Color backgroundColor = Color(0xFFFFFFFB);
  static const Color fieldFillColor = Color(0xFFF7FDFF);

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

  Widget buildProfileField(String label, String value, {double fontSize = 16}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fieldFillColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
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
              bottom: false,
              child: Center(
                child: Text(
                  'الملف الشخصي',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
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
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        buildProfileField('الاسم', userData?['firstname'] ?? "غير متوفر"),
                        buildProfileField('اللقب', userData?['lastname'] ?? "غير متوفر"),
                        buildProfileField('البريد الالكتروني', userData?['email'] ?? "غير متوفر", fontSize: 13),
                        buildProfileField('رقم الهاتف', userData?['phone'] ?? "غير متوفر"),
                        buildProfileField('نوع الحساب', userData?['role'] ?? "غير متوفر"),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/img_18.png'), // <- Your asset image
                        backgroundColor: backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
