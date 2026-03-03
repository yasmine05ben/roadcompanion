import 'package:flutter/material.dart';
import 'paiement.dart'; // Import your existing payment screen
import 'providerUserScreen.dart'; // Import your existing work screen

class ProviderDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 4,
        leading: IconButton(
          icon: Image.asset('assets/return.png', width: 24, height: 24),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        title: Text(
          'لوحة مزود الخدمة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF277DA1),
            fontSize: 22,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.2), // More visible shadow color
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            SizedBox(height: 80),

            // Instructions Section
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Arabic starts from right
                    children: [
                      Text(
                        'تعليمات الدفع والعمل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF277DA1),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('1. يجب تجديد الاشتراك كل شهر لاستمرار الخدمة'),
                      SizedBox(height: 8),
                      Text('2. سيصلك إشعار قبل 10 أيام من موعد الدفع'),
                      SizedBox(height: 8),
                      Text('3. بعد انتهاء المدة لديك يومان للدفع'),
                      SizedBox(height: 8),
                      Text('4. في حالة عدم الدفع سيتم تعطيل الحساب'),
                    ],
                  ),
                ),
              ),
            ),


            SizedBox(height: 35),

            // Payment Button - Now pushes to your existing PaiementScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaiementScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF277DA1),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'دفع الاشتراك',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(height: 15),

            // Work Button - Now pushes to your existing ProviderWorkScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProviderScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF9844A),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إدارة الخدمات',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            // Warning Message

          ],
        ),
      ),
    );
  }
}