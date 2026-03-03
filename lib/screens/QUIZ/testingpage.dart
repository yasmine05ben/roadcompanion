import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';
import 'test_result.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int timeLeft = 40;
  Timer? timer;
  bool answered = false;
  bool confirmed = false;
  int? selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  Future<String> _getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No auth token found.');

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['id'] ?? '';
      if (userId.isEmpty) throw Exception('User ID not found in token.');
      return userId;
    } catch (e) {
      throw Exception('Failed to decode token: $e');
    }
  }
  Future<void> submitResult() async {
    final url = Uri.parse('${Config.baseUrl}/score/attempts'); // Change to your actual endpoint
    String userId = await _getUserIdFromToken();
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId, // Replace with dynamic user ID if available
        'score': score,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Result submitted successfully!");
    } else {
      print("Failed to submit result: ${response.body}");
    }
  }


  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/questions/random'));

    if (response.statusCode == 200) {
      setState(() {
        questions = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print("Failed to load questions");
    }
  }

  void startTimer() {
    timer?.cancel(); // Stop any existing timer
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        nextQuestion();
      }
    });
  }


  void selectAnswer(int index) {
    if (!answered) {
      setState(() {
        selectedIndex = index;
        confirmed = false;
      });
    }
  }

  void confirmAnswer() {
    if (selectedIndex != null) {
      setState(() {
        confirmed = true;
        answered = true;
        timer?.cancel(); // Stop the timer when the answer is confirmed
        if (selectedIndex == int.parse(questions[currentQuestionIndex]['correctAnswer'])) {
          score++;
        }
      });
      _animationController.forward(); // Show explanation bar
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answered = false;
        confirmed = false;
        selectedIndex = null;
        timeLeft = 40;
      });
      _animationController.reverse(); // Hide explanation bar
      startTimer(); // Restart timer for the next question
    } else {
      showResult();
    }
  }

  void showResult() async {
    await submitResult(); // <-- Add this

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultPage(
          score: score,
          totalQuestions: questions.length,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
        title: Text(
        "اختبار قواعد المرور",
        style: TextStyle(
          color: Color(0xFF277DA1),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

    centerTitle: true,
    ),
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
      );
    }
    var question = questions[currentQuestionIndex]; // Now it's safe!
    bool isLastQuestion = currentQuestionIndex == questions.length - 1;

    return Scaffold(
      appBar:  AppBar(
        title: Text(
            "اختبار قواعد المرور",
            style: TextStyle(
              color: Color(0xFF277DA1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10,5,10,5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Home Button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFF277DA1),
                          shape: BoxShape.circle,
                        ),
                        child: Center( // Wrap IconButton with Center for extra safety
                          child: IconButton(
                            icon: Icon(Icons.home, color: Colors.white, size: 35),
                            onPressed: () {
                              Navigator.pop(context); // Navigate to home
                            },
                            padding: EdgeInsets.zero, // Remove default padding
                            alignment: Alignment.center, // Ensure alignment is centered
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                        decoration: BoxDecoration(
                          color: Color(0xFF277DA1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "السؤال : ${currentQuestionIndex + 1}/40",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                      // Timer Display Button
                      Stack(
                        alignment: Alignment.center, // Center the stack content
                        children: [
                          // Background Image
                          ClipOval(
                            child: Image.asset(
                              "assets/TIMER.png", // Replace with your image path
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain, // Ensure the image covers the circle
                            ),
                          ),
                          // Timer Text (Positioned slightly lower)
                          Positioned(
                            bottom: 13, // Adjust this value to move the text up or down
                            child: Text(
                              "00:$timeLeft",
                              style: TextStyle(
                                color: Color(0xFF277DA1),
                                fontSize: 9,
                                fontFamily: 'DS-Digital',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),

                  SizedBox(height: 5),

                  // Question box
                  Container(
                    width: 350,
                    height: 500,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFD7E6EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  question["question"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF277DA1)),
                                  overflow: TextOverflow.ellipsis, // Shortens with "..."
                                  maxLines: 3, // Limits to 2 lines
                                ),
                              ),

                              SizedBox(height: 10),
                              if (question["image"] != null)
                                Container(
                                  width: 300,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade300, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      question["image"],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Choices
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: List.generate(question["options"].length, (index) {
                              // Determine the background color and icon based on the answer state
                              Color circleColor = Color(0xFF277DA1); // Default blue color
                              Widget circleChild = Text(
                                (index + 1).toString(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );

                              if (confirmed) {
                                if (index == int.parse(question['correctAnswer'])) {
                                  // Correct answer: Green circle with checkmark
                                  circleColor = Color(0xFF127F57);
                                  circleChild = Icon(Icons.check, color: Colors.black);
                                } else if (index == selectedIndex) {
                                  // Incorrect answer: Red circle with "X"
                                  circleColor = Color(0xFFC52C38);
                                  circleChild = Icon(Icons.close, color: Colors.black);
                                }
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: SizedBox(
                                  width: 320,
                                  height: 65,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      selectAnswer(index);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: confirmed
                                          ? (index == int.parse(question['correctAnswer'])
                                          ? Color(0xFF84CF9D) // Green for correct answer
                                          : (index == selectedIndex ? Color(0xFFE97B7F) : Colors.white)) // Red for incorrect answer, white otherwise
                                          : (selectedIndex == index ? Color(0xFFB9D3E1) : Colors.white), // Default colors
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible( // ✅ Ensures text wraps properly
                                          child: Text(
                                            question["options"][index],
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontSize: 14),
                                            maxLines: 2, // ✅ Allows wrapping to 2 lines
                                            overflow: TextOverflow.ellipsis, // ✅ Shows "..." if text is too long
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: circleColor,
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: circleChild,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!confirmed)
                    Column(
                      children: [
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: confirmAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF9844A),
                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_sharp, color: Colors.white), // Confirm Icon
                              SizedBox(width: 8),
                              Text("تأكيد الإجابة", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Explanation bar with header
          if (confirmed)
            Stack(
              clipBehavior: Clip.none, // Ensure overflow is allowed
              children: [
                // Explanation Bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: -1,
                    child: Container(
                      width: double.infinity, // Full width
                      height: 170, // Fixed height
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFD7E6EC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20), // Extra space to avoid overlap
                          SizedBox(
                            height: 68, // Set a fixed height for the scrollable area
                            child: SingleChildScrollView(
                              child: Text(
                                questions[currentQuestionIndex]["explanation"],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ),

                          ElevatedButton(
                            onPressed: isLastQuestion ? showResult : nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFB9D3E1),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.double_arrow_rounded, color: Colors.black), // Next Icon
                                SizedBox(width: 8),
                                Text(isLastQuestion ? "انهاء الاختبار" : "انتقل إلى السؤال الموالي", style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating "التوضيح" Label
                Positioned(
                  bottom: 150, // Moves it slightly above the bar
                  left: MediaQuery.of(context).size.width / 2 - 65, // Center it
                  child: Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF9844A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "التوضيح",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),

              ],
            ),

        ],
      ),
    );
  }
}