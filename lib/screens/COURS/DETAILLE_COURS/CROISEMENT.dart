import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/config.dart';
import '/widgets/DETAILS.dart';
import 'package:hive/hive.dart';
class CroisementScreen extends StatefulWidget {
  @override
  _CroisementScreenState createState() => _CroisementScreenState();
}

class _CroisementScreenState extends State<CroisementScreen> {
  List<String> paragraphs = [];
  List<String> images = [];
  bool isLoading = true;
  bool hasError = false;
  TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final box = await Hive.openBox('croisementsBox');

    try {
      final paragraphResponse =
      await http.get(Uri.parse('${Config.baseUrl}/croisements/paragraphes'));
      final imageResponse =
      await http.get(Uri.parse('${Config.baseUrl}/croisements/images'));

      if (paragraphResponse.statusCode == 200 && imageResponse.statusCode == 200) {
        List<dynamic> data1 = jsonDecode(paragraphResponse.body);
        final imageData = jsonDecode(imageResponse.body);

        // Save to Hive
        await box.put('paragraphs', data1);
        await box.put('images', imageData['images']);

        setState(() {
          paragraphs = data1.map((item) => item["description"]?.toString() ?? "").toList();
          images = List<String>.from(imageData['images']);
          isLoading = false;
        });
      } else {
        loadFromHive(box); // fallback
      }
    } catch (e) {
      loadFromHive(box); // fallback
    }
  }

  void loadFromHive(Box box) {
    final cachedParagraphs = box.get('paragraphs', defaultValue: []);
    final cachedImages = box.get('images', defaultValue: []);

    setState(() {
      paragraphs = (cachedParagraphs as List)
          .map((item) => item["description"]?.toString() ?? "")
          .toList();
      images = List<String>.from(cachedImages);
      hasError = false;
      isLoading = false;
    });
  }



  void updateSearchText(String query) {
    setState(() {
      searchText = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "المقاطعة",
        imagePath: "assets/croisement.png",
        textColor: Color(0xFFC52C38),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
          child: Text(
            "فشل تحميل البيانات، حاول مرة أخرى.",
            style: TextStyle(color: Colors.red),
          ))
          : Column(
        children: [
          SizedBox(height: 20), // ✅ Added space between AppBar and Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // ✅ Adjusted padding
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // ✅ White background
                borderRadius: BorderRadius.circular(30), // ✅ Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // ✅ Soft shadow
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: updateSearchText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "....ابحث",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  border: InputBorder.none, // ✅ Removed default border
                  suffixIcon: Container(
                    margin: EdgeInsets.all(4), // ✅ Adjusted margin
                    decoration: BoxDecoration(
                      color: Colors.red[600], // ✅ Blue background
                      shape: BoxShape.circle, // ✅ Circular icon background
                    ),
                    child: Icon(Icons.search, color: Colors.white, size: 25),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 0), // Adjust the height value as needed

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildContent() {
    List<Widget> contentList = [];

    int itemCount = paragraphs.length > images.length
        ? paragraphs.length
        : images.length;
    contentList.add(SizedBox(height: 20));

    for (int i = 0; i < itemCount; i++) {
      if (i < paragraphs.length) {
        contentList.add(
          highlightText(paragraphs[i], searchText),
        );
        contentList.add(SizedBox(height: 10));
      }

      if (i < images.length) {
        contentList.add(
          Image.asset(
            images[i],
            width: 410,
            height: 150,
            fit: BoxFit.contain,
          ),
        );
        contentList.add(SizedBox(height: 20));
      }
    }

    return contentList;
  }

  /// ✅ Fonction pour mettre en surbrillance le texte recherché
  Widget highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    }

    List<TextSpan> spans = [];
    int start = 0;
    while (start < text.length) {
      int index = text.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      // ✅ Partie avant le mot recherché
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      // ✅ Mot recherché en surbrillance
      spans.add(
        TextSpan(
          text: query,
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
      start = index + query.length;
    }

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 18, color: Colors.black),
        children: spans,
      ),
    );
  }
}
