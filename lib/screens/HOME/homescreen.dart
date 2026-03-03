import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import '/screens/ASSISTANCE/PROVIDER/service.dart';
import '../COURS/learningpage.dart';
import '../QUIZ/intro_pages.dart';
import '../NAVIGATION_MAP/map_screen.dart';
import '../ASSISTANCE/USER_REQUEST/assistancepage.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../SETTINGS/settings_screen.dart';
import '../SETTINGS/help_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'profilescreen2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _intpage = 0;
  GlobalKey<CurvedNavigationBarState> _curvenavigationkey = GlobalKey();
  Widget _profileScreen = UserProfileScreen1();
  Widget _assistance = CircularSlidingChoices();
  String name = "";
  bool _isLoading = false;

  int unreadNotifications = 0;

  @override
  @override
  void initState() {
    super.initState();
    // Go to UI first, fetch in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData().then((_) {
        fetchUnreadNotifications();
      });
      _startNotificationRefresh();
    });
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print("❌ No token found");
      setState(() => _isLoading = false);
      return;
    }

    try {
      Map<String, dynamic> payload = decodeToken(token);
      final role = payload["role"] ?? "مستخدم عادي";
      final firstName = payload["firstname"] ?? "";
      final userId = payload["id"];  // Corrected to fetch 'id' instead of 'userId'

      if (userId == null) {
        print("❌ userId (id) not found in token payload");
      } else {
        // Save the userId to SharedPreferences
        await prefs.setString('user_id', userId);
        print("✅ userId saved: $userId");

        // Ensure the userId is saved before calling fetchUnreadNotifications
        await Future.delayed(Duration(milliseconds: 500));  // Small delay to ensure data is saved
        fetchUnreadNotifications();
      }

      setState(() {
        name = firstName;
        _profileScreen = (role == "مستخدم عادي") ? UserProfileScreen1() : UserProfileScreen2();
        _assistance = (role == "مستخدم عادي") ? CircularSlidingChoices() : ProviderDashboardPage();
      });
    } catch (e) {
      print('❌ Error decoding token: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      print("❌ No user ID found");
      return;
    }

    try {
      print("Fetching notifications for user ID: $userId");  // Log the userId being used
      final response = await http.get(Uri.parse('${Config.baseUrl}/notif/notifications/unread/count/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            unreadNotifications = data['unreadCount'];
          });
        } else {
          setState(() {
            unreadNotifications = 0;
          });
        }
      } else {
        print('❌ Failed to fetch unread notifications. Status Code: ${response.statusCode}');
        setState(() {
          unreadNotifications = 0;
        });
      }
    } catch (e) {
      print('❌ Error fetching unread notifications: $e');
      setState(() {
        unreadNotifications = 0;
      });
    }
  }

  void _startNotificationRefresh() {
    // Start auto-refresh notifications every 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      fetchUnreadNotifications();
      _startNotificationRefresh(); // Repeat after 30 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double screenWidth = MediaQuery.of(context).size.width;
    final List<Widget> _pages = [
      HomePageContent(name: name, assistance: _assistance),
      NotificationsScreen(),
      _profileScreen,
      SettingsScreen(),
    ];

    return Scaffold(

      bottomNavigationBar: CurvedNavigationBar(
        key: _curvenavigationkey,
        index: _intpage,
        height: 65.0,
        items: [
          Icon(Icons.home, size: 33, color: Colors.white),
          _buildNotificationIcon(),
          Icon(Icons.person, size: 33, color: Colors.white),
          Icon(Icons.settings, size: 33, color: Colors.white),
        ],
        color: Color(0xFF277DA1),
        buttonBackgroundColor: Color(0xFF277DA1),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _intpage = index;
            if (index == 1) {
              // If Notifications tab opened, reset unread notifications
              unreadNotifications = 0;
            }
          });
        },
      ),
      body: _pages[_intpage],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications, size: 33, color: Colors.white),
        if (unreadNotifications > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  unreadNotifications.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String name;
  final Widget assistance;

  const HomePageContent({required this.name, required this.assistance});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
      // Background blue curve
      Positioned(
      top: -100,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: ProsteThirdOrderBezierCurve(
          position: ClipPosition.bottom,
          list: [
            ThirdOrderBezierCurveSection(
              p1: Offset(2, 900),
              p2: Offset(-70, 150),
              p3: Offset(screenWidth, 400),
              p4: Offset(screenWidth, 200),
            ),
          ],
        ),
        child: Container(
          height: 500,
          color: Color(0xFF277DA1),
        ),
      ),
    ),

    // White header (replacing CustomHeader)
    Positioned(
    top: 0,
    left: 5,
    right: 0,
    child: ClipPath(
    clipper: ProsteThirdOrderBezierCurve(
    position: ClipPosition.bottom,
    list: [
    ThirdOrderBezierCurveSection(
    p1: Offset(2, 900),
    p2: Offset(0, 300),
    p3: Offset(screenWidth, 550),
    p4: Offset(screenWidth, 300),
    ),
    ],
    ),
    child: Container(
    height: 225,
    color: Colors.transparent,
    ),
    ),
    ),

    // Main content grid
    Positioned(
    top: 220, // Position below header
    left: 0,
    right: 0,
    bottom: 0,
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 3,
    mainAxisSpacing: 3,
    childAspectRatio: 0.8,
    children: [
    GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => learningpage())),
    child: StaggeredGridItem("assets/img.png", "تعلم قواعد المرور", isLeft: true),
    ),
    GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPages())),
    child: StaggeredGridItem("assets/img_5.png", "اختبار قواعد المرور", isLeft: false),
    ),
    GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen())),
    child: StaggeredGridItem("assets/img_3.png", "نظام التوجيه الذكي", isLeft: true),
    ),
    GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => assistance)),
    child: StaggeredGridItem("assets/img_6.png", "المساعدة الآلية", isLeft: false),
    ),
    ],
    ),
    ),
    ),

    // Profile section
    Positioned(
    top: 50,
    right: 20,
    child: Row(
    children: [
    Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    Text(
    "مرحبا !",
    textDirection: TextDirection.rtl,
    style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white
    ),
    ),
    Text(
    name,
    style: TextStyle(
    fontSize: 16,
    color: Colors.white70
    ),
    ),
    ],
    ),
    SizedBox(width: 10),
    Container(
    width: 57,
    height: 56,
    decoration: ShapeDecoration(
    color: Colors.white,
    shape: OvalBorder(),
    ),
    child: Center(
    child: Icon(Icons.person, size: 30, color: Colors.grey),
    ),
    ),
    ],
    ),
    ),

    // Help button
    Positioned(
    top: 50,
    left: 20,
    child: GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen())),
    child: CircleAvatar(
    radius: 20,
    backgroundColor: Colors.white.withOpacity(0.3),
    child: Icon(Icons.info_outline, size: 24, color: Colors.white),
    ),
    ),
    ),

    // Center logo
    Positioned(
    top: screenHeight * 0.54,
    left: screenWidth * 0.35,
    child: Container(
    width: 105,
    height: 105,
    decoration: BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 10,
    offset: Offset(1, 10),
    spreadRadius: -5,
    ),
    ],
    ),
    child: Center(
    child: Transform.translate(
    offset: Offset(0, 5),
    child: Image.asset(
    'assets/img_8.png',
    width: 70,
    height: 80,
    fit: BoxFit.contain,
    ),
    ),
    ),
    ),
    ),
    ],
    );
  }
}

class CustomHeader extends StatelessWidget {
  final double screenWidth;

  const CustomHeader(this.screenWidth, {super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 5,
      right: 0,
      child: ClipPath(
        clipper: ProsteThirdOrderBezierCurve(
          position: ClipPosition.bottom,
          list: [
            ThirdOrderBezierCurveSection(
              p1: Offset(2, 900),
              p2: Offset(0, 300),
              p3: Offset(screenWidth, 550),
              p4: Offset(screenWidth, 300),
            ),
          ],
        ),
        child: Container(
          height: 225,
          color: Colors.white,
          child: Column(children: [SizedBox(height: 50)]),
        ),
      ),
    );
  }
}

class StaggeredGridItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final bool isLeft;
  final double boxWidth;
  final double boxHeight;

  const StaggeredGridItem(this.imagePath, this.title, {super.key, required this.isLeft, this.boxWidth = 150, this.boxHeight = 190});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, isLeft ? -10 : 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: boxWidth,
          height: boxHeight,
          decoration: BoxDecoration(
            color: Color(0xFF277DA1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(65),
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 100, offset: Offset(1, 10), spreadRadius: -5)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.values[2],
            children: [
              Image.asset(imagePath, width: 150, height: 100),
              const SizedBox(height: 0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF277DA1),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
