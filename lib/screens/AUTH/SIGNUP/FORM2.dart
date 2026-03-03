import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../login.dart';
import '/config.dart';
class FormScreen2 extends StatefulWidget {
  final String email; // NEW: Email parameter

  FormScreen2({required this.email});
  @override
  _FormScreenState2 createState() => _FormScreenState2();
}

class _FormScreenState2 extends State<FormScreen2> {
  final _formKey = GlobalKey<FormState>();
  File? _image1, _image2, _image3;
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool image1Error = false;
  bool image2Error = false;
  bool image3Error = false;
  bool colorPhone = false;
  String? errorPhone;
  bool colorAddress = false;
  String? errorAddress;

  Future<void> _pickImage(ImageSource source, int imageNumber) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
          image1Error = false;
        }
        if (imageNumber == 2) {
          _image2 = File(pickedFile.path);
          image2Error = false;
        }
        if (imageNumber == 3) {
          _image3 = File(pickedFile.path);
          image3Error = false;
        }
      });
    }
  }


  Future<void> _submitForm() async {
    setState(() {
      image1Error = _image1 == null;
      image2Error = _image2 == null;
      image3Error = _image3 == null;

      colorAddress = _addressController.text.isEmpty;
      colorPhone = _phoneController.text.isEmpty;

      errorAddress = colorAddress ? "يرجى إدخال العنوان" : null;
      errorPhone = colorPhone ? "يرجى إدخال رقم الهاتف" : null;

      if (image1Error || image2Error || image3Error || colorAddress || colorPhone) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى ملء جميع الحقول وإضافة الصور")),
        );
        return;
      }
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/auth/upgrade'),
      );
      Future<void> addImage(File? image, String fieldName) async {
        if (image != null) {
          String? mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          List<String> mimeParts = mimeType.split('/');

          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              image.path,
              contentType: MediaType(mimeParts[0], mimeParts[1]), // Correct usage of MediaType
            ),
          );
        }
      }
      // Attach images if they are selected
      await addImage(_image1, 'profilePhoto');
      await addImage(_image2, 'commerceRegister');
      await addImage(_image3, 'carteidentite');

      // Attach text fields
      request.fields['email'] = widget.email;
      request.fields['businessAddress'] = _addressController.text;
      request.fields['phonePro'] = _phoneController.text;

      // Send request
      var response = await request.send();

      // Convert response to a readable format
      var responseBody = await http.Response.fromStream(response);


      if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل إرسال البيانات! حاول مرة أخرى ${responseBody.body}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم إرسال البيانات بنجاح!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الإرسال")),
      );
    }
  }
  Widget _buildImagePicker(int imageNumber, File? imageFile, bool hasError, String labelText, String hintText,String IMGPATH) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            labelText,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: hasError ? Colors.red : Color(0xFF277DA1),
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text("اختر من المعرض"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, imageNumber);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("التقط صورة"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, imageNumber);
                    },
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: hasError ? Colors.red.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: hasError ? Colors.red : Color(0xFF277DA1),
                width: 2.0,
              ),
            ),
            child: imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.file(imageFile, fit: BoxFit.cover),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: hasError ? Colors.red : Colors.grey, size: 30),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hintText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: hasError ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child:Image.asset(
                    IMGPATH,
                    width: 22,
                    height: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 5, right: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "يرجى اختيار صورة",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                Text(
                  'معلوماتك المهنية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF277DA1),
                  ),
                ),
                SizedBox(height: 40),

                _buildImagePicker(1, _image1, image1Error, " الصورة الشخصية (خلفية بيضاء)", "أدخل صورتك الشخصية",'assets/img_15.png'),
                SizedBox(height: 30),
                _buildImagePicker(2, _image2, image2Error, " بطاقة الهوية", "أدخل بطاقة هويتك",'assets/img_16.png'),
                SizedBox(height: 30),
                _buildImagePicker(3, _image3, image3Error, " السجل التجاري", "أدخل السجل التجاري",'assets/img_17.png'),

                SizedBox(height: 50),

                // Address Input
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _addressController,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          labelText: 'عنوان العمل',
                          labelStyle: TextStyle(
                            color: Color(0xFF277DA1),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                          ),
                          hintText: 'أدخل عنوان عملك',
                          hintStyle: TextStyle(
                            color: Color(0xFFA1A1A1),
                            fontFamily: 'Montserrat',
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/img_14.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: colorAddress ? Colors.red : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: colorAddress ? Colors.red : Color(0xFF277DA1),
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: colorAddress ? Colors.red.shade50 : Colors.white,
                        ),
                      ),
                      if (colorAddress && errorAddress != null)
                        Padding(
                          padding: EdgeInsets.only(top: 5, right: 10),
                          child: Text(
                            errorAddress!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 50),

                // Phone Input
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _phoneController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: ' رقم الهاتف المهني',
                          labelStyle: TextStyle(
                            color: Color(0xFF277DA1),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                          ),
                          hintText: 'أدخل رقم هاتفك المهني',
                          hintStyle: TextStyle(
                            color: Color(0xFFA1A1A1),
                            fontFamily: 'Montserrat',
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/iconphone.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: colorPhone ? Colors.red : Colors.grey,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: colorPhone ? Colors.red : Color(0xFF277DA1),
                              width: 2.0,
                            ),
                          ),
                          filled: true,
                          fillColor: colorPhone ? Colors.red.shade50 : Colors.white,
                        ),
                      ),
                      if (colorPhone && errorPhone != null)
                        Padding(
                          padding: EdgeInsets.only(top: 5, right: 10),
                          child: Text(
                            errorPhone!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 50),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF9844A),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'إنشاء حساب',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
