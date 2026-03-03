import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String imagePath;
  final Color textColor;

  CustomAppBar({required this.title, required this.imagePath, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: AppBarPainter())),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Transform.translate(
                offset: Offset(0.0, 20.0),
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Transform.translate(
                offset: Offset(0.0, 20.0),
                child: SizedBox(
                  height: 55,
                  child: Image.asset(imagePath, filterQuality: FilterQuality.high),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class AppBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.4, size.height);
    path.quadraticBezierTo(size.width * 0.5, size.height + 50, size.width * 0.6, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 8.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}