import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/DETAILS.dart';
import 'DTSTOP.dart';
import '/config.dart';
import 'package:hive/hive.dart';
class IntroductionScreenSTOP extends StatefulWidget {
  @override
  _IntroductionScreenSTOPState createState() => _IntroductionScreenSTOPState();
}

class _IntroductionScreenSTOPState extends State<IntroductionScreenSTOP> {
  String? category;
  String? explanation;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchIntroductionData();
  }

  Future<void> fetchIntroductionData() async {
    final box = await Hive.openBox('panneauxRoutesArretStopBox');

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/panneauxRoutes/explication/arret_stop'));

      if (response.statusCode == 404) {
        throw Exception("Failed to load data");
      } else {
        final data = jsonDecode(response.body);

        // Save to Hive
        await box.put('category', data['categorie'] ?? "عنوان غير متوفر");
        await box.put('explanation', data['explication'] ?? "لا يوجد شرح متاح.");

        setState(() {
          category = data['categorie'] ?? "عنوان غير متوفر";
          explanation = data['explication'] ?? "لا يوجد شرح متاح.";
          isLoading = false;
        });
      }
    } catch (e) {
      loadFromHive(box);
    }
  }

  void loadFromHive(Box box) {
    final cachedCategory = box.get('category', defaultValue: "عنوان غير متوفر");
    final cachedExplanation = box.get('explanation', defaultValue: "لا يوجد شرح متاح.");

    setState(() {
      category = cachedCategory;
      explanation = cachedExplanation;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "قانون الطرقات وعلامات الطريق",
        imagePath: "assets/img_19.png",
        textColor: Color(0xFFC4931D),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Show loading indicator
          : hasError
          ? Center(child: Text("فشل تحميل البيانات، حاول مرة أخرى.", style: TextStyle(color: Colors.red)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '   علامات الوقوف والتوقف',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:Color(0xFF277DA1),),
            ),
            SizedBox(height: 20),
            Text(
              explanation!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignListScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade100,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'التالي',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
