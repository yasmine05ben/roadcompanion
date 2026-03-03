import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '/config.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'testingpage.dart'; // Adjust path if needed

class PastAttemptsScreen extends StatefulWidget {
  @override
  _PastAttemptsScreenState createState() => _PastAttemptsScreenState();
}

class _PastAttemptsScreenState extends State<PastAttemptsScreen> {
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<String> _getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No auth token found.');
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'] ?? '';
    } catch (e) {
      throw Exception('Failed to decode token: $e');
    }
  }

  Future<void> fetchResults() async {
    try {
      final userId = await _getUserIdFromToken();
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/score/attempts/$userId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          results = jsonDecode(response.body);
        });
      } else {
        print("Failed to load results: ${response.body}");
      }
    } catch (e) {
      print("Error fetching results: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محاولات سابقة", style: TextStyle(color: Color(0xFF277DA1))),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF277DA1)),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'هل تريد تحسين مهاراتك في القيادة؟',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: const Color(0xFF277DA1),
              fontSize: 23,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              // The image
              Image.asset(
                'assets/img_286.png',
                width: double.infinity,
                height: 150,
                fit: BoxFit.contain,
              ),

              // The button
              Positioned(
                bottom: 50,
               right: 30,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => QuizScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCD5F59),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "ابدأ الاختبار الآن!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // Subtitle below the image
          Text(
            "اطلع على نتائجك السابقة وحسن مستواك!",
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: const Color(0xFF277DA1),
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final score = item['score'] ?? 0;
                final percent = (score / 40).clamp(0.0, 1.0);
                final dateTime = DateTime.parse(item['createdAt']);
                final date = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
                final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Circle on the left
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 6.0,
                          percent: percent,
                          center: Text(
                            "$score / 40",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          progressColor: Color(0xFF277DA1),
                          backgroundColor: Colors.grey.shade300,
                          animation: true,
                        ),
                        SizedBox(width: 50),
                        // Text aligned to the right side
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                "المحاولة ${index + 1}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF277DA1),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "التاريخ: $date",
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                "الوقت: $time",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // "New Attempt" Button

        ],
      ),
    );
  }
}
