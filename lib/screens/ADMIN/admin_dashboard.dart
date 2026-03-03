import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_Incidents.dart';
import 'ManagePaiements.dart';
import '../AUTH/login.dart';// Importer la page de gestion des paiements

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // ✅ Réinitialiser la valeur de 'first_time'
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('first_time', true);

              // ✅ Naviguer vers l'écran de connexion
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );

              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Directionality(
                      textDirection: TextDirection.rtl,
                      child: const Text(
                        'تم تسجيل الخروج بنجاح',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Ligne contenant l’image et le texte de bienvenue
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade300, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 7,
                          spreadRadius: 8,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image300.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "مرحبا !",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "مدير النظام",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Boutons d'administration
              AdminButton(
                title: 'إدارة التبليغات والتنبيهات',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageIncidents()),
                  );
                },
              ),
              SizedBox(height: 15),
              AdminButton(
                title: 'إدارة المستخدمين',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageUsers()),
                  );
                },
              ),
              SizedBox(height: 15),
              AdminButton(
                title: 'إدارة عمليات الدفع',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManagePaiements()),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// Widget stylisé pour les boutons
class AdminButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  AdminButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.blue.shade100, // Remettre le bleu clair d’origine
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
