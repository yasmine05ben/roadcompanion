import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:http/http.dart' as http;
import 'package:raodsafety/screens/AUTH/login.dart';
import 'dart:convert';
import 'FORM2.dart';
import '/config.dart';

class FormScreen extends StatefulWidget {

  final String email;

  FormScreen({required this.email});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();


  String? selectedAccountType;
  String? selectedGender; // Gender selection state

  final _formKey = GlobalKey<FormState>();
  String? errorName;
  String? errorLastName;
  String? errorSex;
  String? errorRole;
  bool colorSexError = false;
  bool colorName = false;
  bool colorLastName = false;
  bool colorRole = false;

  Future<void> _form() async {
    bool hasError = false;

    // Name Validation
    if (_nameController.text.isEmpty) {
      setState(() {
        errorName = "الرجاء إدخال الاسم";
        colorName = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorName = null;
        colorName = false;
      });
    }

    // Last Name Validation
    if (_lastnameController.text.isEmpty) {
      setState(() {
        errorLastName = "الرجاء إدخال اللقب";
        colorLastName = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorLastName = null;
        colorLastName = false;
      });
    }

    // Sex Validation
    if (selectedGender == null) {
      setState(() {
        errorSex = "الرجاء تحديد الجنس";
        colorSexError = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorSex = null;
        colorSexError = false;
      });
    }

    // Role Validation
    if (selectedAccountType == null) {
      setState(() {
        errorRole = "الرجاء تحديد نوع الحساب";
        colorRole = true;
      });
      hasError = true;
    } else {
      setState(() {
        errorRole = null;
        colorRole = false;
      });
    }

    if (hasError) return; // Stop if any validation fails

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/formulaire1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'firstname': _nameController.text.trim(),
          'lastname': _lastnameController.text.trim(),
          'sex': selectedGender,
          'role': selectedAccountType,
        }),
      );



      if (response.statusCode == 404) {
        setState(() {
          colorName = true;
          colorLastName = true;
          colorSexError = true;
          colorRole = true;
        });
      } else { if (selectedAccountType?.trim() == 'مستخدم عادي'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );}else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FormScreen2(email:widget.email)),);
      }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال بالخادم")),
      );
    }
  }

  Widget buildGenderOption(String label, String imagePath, String gender) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedGender == gender ? Color(0xFFDCE9EE) : Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(
            color: colorSexError ? Colors.red : Colors.grey,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          setState(() {
            selectedGender = gender;
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min, // Prevents button from stretching
          children: [
            Image.asset(
              imagePath, // Image file path
              width: 24, // Adjust image size
              height: 24,
            ),
            SizedBox(width: 8), // Space between image and text
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF277DA1),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: ProsteThirdOrderBezierCurve(
                    position: ClipPosition.bottom,
                    list: [
                      ThirdOrderBezierCurveSection(
                        p1: Offset(2, 550),
                        p2: Offset(0, 150),
                        p3: Offset(screenWidth, 350),
                        p4: Offset(screenWidth, 100),
                      ),
                    ],
                  ),
                  child: Container(
                    height: 350,
                    width: screenWidth,
                    color: const Color(0xFFd7e6ec),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(
                          'assets/img_9.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 300,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'إنشاء حساب جديد!',
                      textAlign: TextAlign.center,textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF277DA1),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Directionality(
                          textDirection: TextDirection.rtl, // Enforce RTL
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  textAlign: TextAlign.right,

                                  decoration: InputDecoration(
                                    labelText: 'الاسم ',
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF277DA1),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                    hintText: 'أدخل الاسم ',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFA1A1A1),
                                      fontFamily: 'Montserrat',
                                    ),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/img_11.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorName ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorName ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorName ? Colors.red : Color(0xFF277DA1), // Blue when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: colorName ? Colors.red.shade50 : Colors.white,
                                  ),
                                ),
                                if (colorName && errorName != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, right: 10),
                                    child: Text(
                                      errorName!,
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                              ]
                          )
                      ),
                      const SizedBox(height: 25),

                      Directionality(
                          textDirection: TextDirection.rtl, // Enforce RTL
                          child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _lastnameController,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    labelText: 'اللقب',
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF277DA1),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                    ),
                                    hintText: 'أدخل اللقب',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFA1A1A1),
                                      fontFamily: 'Montserrat',
                                    ),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/img_11.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorLastName ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorLastName ? Colors.red : Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: colorLastName ? Colors.red : Color(0xFF277DA1), // Change color when focused
                                        width: 2.0,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: colorLastName ? Colors.red.shade50 : Colors.white,
                                  ),
                                ),
                                if (colorLastName && errorLastName != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, right: 10),
                                    child: Text(
                                      errorLastName!,
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                              ]
                          )
                      ),


                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildGenderOption("ذكر", 'assets/img_10.png', "ذكر"),
                          buildGenderOption("أنثى", 'assets/Vector4.png', "أنثى"),
                        ],
                      ),
                      if (errorSex != null)
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                         child: Align(
                           alignment: Alignment.centerRight,
                          child: Text(errorSex!, style: TextStyle(fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.red)),
                        ),),
                      const SizedBox(height: 25),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl, // Enforce right-to-left text
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "نوع الحساب",
                                labelStyle: TextStyle(
                                  color: const Color(0xFF277DA1),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                                hintText: 'اختر نوع حسابك',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA1A1A1),
                                  fontFamily: 'Montserrat',
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/img_11.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: colorRole ? Colors.red : Colors.grey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: colorRole ? Colors.red : Colors.grey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color: colorRole ? Colors.red : Color(0xFF277DA1), // Blue when focused
                                    width: 2.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorRole ? Colors.red.shade50 : Colors.white,
                              ),
                              items: ["ميكانيكي", "مستخدم عادي", "عامل سحب السيارات", "بائع قطع الغيار"].map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Align(
                                    alignment: Alignment.centerRight, // Align text inside dropdown to the right
                                    child: Text(type),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAccountType = value;
                                });
                              },
                            ),
                          ),

                          if (colorRole && errorRole != null)
                            Padding(
                              padding: EdgeInsets.only(top: 5), // Space below the dropdown
                              child: Align(
                                alignment: Alignment.centerRight, // Align error text to the right
                                child: Text(
                                  errorRole!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:_form ,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF9844A),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ); }}