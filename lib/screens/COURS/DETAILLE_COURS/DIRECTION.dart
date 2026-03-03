import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/config.dart';
import '/widgets/DETAILS.dart';
import 'package:hive/hive.dart';
class DirectionScreen extends StatefulWidget {
  @override
  _DirectionScreenState createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  List<String> paragraphs = [];
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
    final box = await Hive.openBox('intersectionsBox');

    try {
      final paragraphResponse =
      await http.get(Uri.parse('${Config.baseUrl}/intersections/paragraphes'));

      if (paragraphResponse.statusCode == 200) {
        List<dynamic> data = jsonDecode(paragraphResponse.body);

        // Save to Hive
        await box.put('paragraphs', data);

        setState(() {
          paragraphs = data.map((item) => item["description"]?.toString() ?? "").toList();
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

    setState(() {
      paragraphs = (cachedParagraphs as List)
          .map((item) => item["description"]?.toString() ?? "")
          .toList();
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
        title: "تغيير الاتجاه بالمفترقات",
        imagePath: "assets/direction.png",
        textColor: Color(0xFFC52C38),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
          child: Text("فشل تحميل البيانات، حاول مرة أخرى.",
              style: TextStyle(color: Colors.red)))
          : Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
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
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  border: InputBorder.none,
                  suffixIcon: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search, color: Colors.white, size: 25),
                  ),
                ),
              ),
            ),
          ),
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
    contentList.add(SizedBox(height: 20));

    for (String paragraph in paragraphs) {
      contentList.add(highlightText(paragraph, searchText));
      contentList.add(SizedBox(height: 10));
    }

    return contentList;
  }

  /// ✅ Function to highlight searched text
  Widget highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: query,
          style: TextStyle(color: Color(0xFFC52C38), fontWeight: FontWeight.bold, fontSize: 22),
        ),
      );
      start = index + query.length;
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 20, color: Colors.black),
        children: spans,
      ),
    );
  }
}
