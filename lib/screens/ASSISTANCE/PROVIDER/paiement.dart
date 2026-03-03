import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '/config.dart';

class PaiementScreen extends StatefulWidget {
  @override
  _PaiementScreenState createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  File? _image;
  bool _loading = false;

  // Decoding only the userId from the token
  Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("❌ Invalid Token: $e");
      return {};
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> envoyerPaiement() async {
    if (_image == null) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("❌ No token found");
      setState(() => _loading = false);
      return;
    }

    try {
      // Decode the token and extract only the user ID
      Map<String, dynamic> payload = decodeToken(token);
      final userId = payload["id"]; // Extract the user ID

      print("User ID: $userId"); // You can use this user ID for further operations

      var uri = Uri.parse("${Config.baseUrl}/paiement/payer");
      var request = http.MultipartRequest('POST', uri)
        ..fields['userId'] = userId.toString()  // Send the userId as a field
        ..files.add(await http.MultipartFile.fromPath('recu', _image!.path));

      // Add Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم إرسال الدفع بنجاح.")),
        );
      } else {
        final body = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ فشل: ${jsonDecode(body)['message']}")),
        );
      }
    } catch (e) {
      print("Erreur: $e"); // Error logging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ حدث خطأ أثناء الإرسال.")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(" التقط صورة"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(" اختر من المعرض"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // Arabic text right-to-left
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white, // 👈 This makes the whole screen white
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.black12,
          elevation: 2,
          automaticallyImplyLeading: false, // Prevent default behavior
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Return Icon on the LEFT
              IconButton(
                icon: Image.asset('assets/return.png', width: 24, height: 24),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              // Title on the RIGHT
              Text(
                'إرسال إيصال الدفع',
                style: TextStyle(
                  color: const Color(0xFF277DA1),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,

                ),
              ),
            ],
          ),
        ),


        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                "📄 الرجاء تحميل إيصال الدفع الخاص بك ",
                style: TextStyle(
                  color: const Color(0xFF277DA1),
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,

                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 26),
              _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_image!, height: 200),
              )
                  : Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Icon(Icons.receipt_long, size: 80, color: Colors.grey[600]),
              ),
              SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: showImageSourceDialog,
                icon: Icon(Icons.upload_file,color: Colors.white),
                label: Text(

                  'تحميل الإيصال',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Colors.white


                  ),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Color( 0XFF277DA1),
                ),

              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : envoyerPaiement,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "📨 إرسال الدفع",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: Colors.white

                  ),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
