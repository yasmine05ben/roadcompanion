import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/DETAILS.dart';
import '/config.dart';
import 'package:hive/hive.dart';
class temp_sc extends StatefulWidget {
  @override
  _temp_scState createState() => _temp_scState();
}

// ✅ Sign List Screen
class _temp_scState extends State<temp_sc> {
  List<Map<String, String>> signs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSigns();
  }

  // ✅ Function to fetch signs from the backend
  Future<void> fetchSigns() async {
    final box = await Hive.openBox('panneauxRoutesBox');

    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/panneauxRoutes/exemple/temp'));

      if (response.statusCode == 404) {
        throw Exception('Failed to load signs');
      } else {
        List<dynamic> data = json.decode(response.body);

        // Convert the List<dynamic> into List<Map<String, String>>
        List<Map<String, String>> signsList = data.map((item) {
          return {
            "image": item["image"]?.toString() ?? "", // Ensure it handles missing "image"
            "description": item["description"]?.toString() ?? "" // Ensure it handles missing "description"
          };
        }).toList();

        // Save data to Hive
        await box.put('signs_temp', signsList);

        setState(() {
          signs = signsList;
          isLoading = false;
        });
      }
    } catch (e) {
      loadFromHive(box); // Fallback to Hive data if fetching fails
    }
  }

// Function to load signs from Hive if offline or fetching fails
  void loadFromHive(Box box) {
    final cachedData = box.get('signs_temp', defaultValue: []);

    List<Map<String, String>> cachedSigns = [];
    if (cachedData is List) {
      cachedSigns = cachedData.map<Map<String, String>>((item) {
        final map = Map<String, String>.from(item);
        return map;
      }).toList();
    }

    setState(() {
      signs = cachedSigns;
      isLoading = false;

      if (cachedSigns.isEmpty) {
        print('No cached data available.');
      }
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
        body:Column(
            children: [
              SizedBox(height: 30), // 👈 Adds space between AppBar and GridView
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: signs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 1), // Grey border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3), // Shadow color
                            offset: Offset(0, 4), // Shadow direction (down)
                            blurRadius: 4, // Blur intensity
                            spreadRadius: 0, // Spread intensity
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignDetailScreen(signs: signs, currentIndex: index)));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.white, // Keep button white inside container
                          shadowColor: Colors.transparent, // Remove default ElevatedButton shadow
                        ),
                        child:
                        Image.asset(signs[index]["image"]!, width: 70, height: 70),


                      ),
                    );

                  },
                ),)])
    );
  }
}

// ✅ Sign Detail Screen
class SignDetailScreen extends StatefulWidget {
  final List<Map<String, String>> signs;
  final int currentIndex;

  SignDetailScreen({required this.signs, required this.currentIndex});

  @override
  _SignDetailScreenState createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.currentIndex;
  }

  void navigate(int step) {
    int newIndex = index + step;
    if (newIndex >= 0 && newIndex < widget.signs.length) {
      setState(() {
        index = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var sign = widget.signs[index];

    return Scaffold(backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "قانون الطرقات وعلامات الطريق",
        imagePath: "assets/img_19.png",
        textColor: Color(0xFFC4931D),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                width: 325,
                height: 400,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFA2ABBD)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: [
                    BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4), spreadRadius: 0),
                  ],
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [ SizedBox(height: 150),
                Image.asset(sign["image"]!, width: 200, height: 200, fit: BoxFit.contain),
                SizedBox(height: 20),
                Padding(padding: const EdgeInsets.all(16.0), child: Text(sign["description"]!, textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
                SizedBox(height: 100),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  ElevatedButton(onPressed: index > 0 ? () => navigate(-1) : null, child: SizedBox(width: 50, height: 50, child: Image.asset("assets/arrow2.png"))),
                  ElevatedButton(onPressed: index < widget.signs.length - 1 ? () => navigate(1) : null, child: SizedBox(width: 50, height: 50, child: Image.asset("assets/arrow1.png"))),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
