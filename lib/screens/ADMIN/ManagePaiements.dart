import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import '/widgets/DETAILS.dart';
import '/config.dart';



class Paiement {
  final String id;
  final String userEmail;
  final String userName;
  final String userRole;
  final String mois;
  final String preuvePaiement;
  String statut;
  final DateTime createdAt;

  Paiement({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.userRole,
    required this.mois,
    required this.preuvePaiement,
    required this.statut,
    required this.createdAt,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] ?? {};
    return Paiement(
      id: json['_id'] ?? '',
      userEmail: user['email'] ?? 'غير معروف',
      userName: "${user['firstname'] ?? ''} ${user['lastname'] ?? ''}",
      userRole: user['role'] ?? 'غير محدد',
      mois: json['mois'] ?? '',
      preuvePaiement: json['preuvePaiement'] ?? '',
      statut: json['statut'] ?? 'قيد الانتظار',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class ManagePaiements extends StatefulWidget {
  @override
  State<ManagePaiements> createState() => _ManagePaiementsState();
}

class _ManagePaiementsState extends State<ManagePaiements> {
  List<Paiement> paiements = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPaiements();
  }

  Future<void> fetchPaiements() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/admin/paiements'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['paiements'] is List) {
          List<Paiement> loaded = (data['paiements'] as List)
              .map((json) => Paiement.fromJson(json))
              .toList();
          setState(() {
            paiements = loaded;
            isLoading = false;
          });
        } else {
          throw Exception("Format réponse invalide");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "⚠️ Erreur chargement paiements: ${e.toString()}";
      });
    }
  }

  Future<void> _validerPaiement(Paiement paiement) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/admin/${paiement.id}/valider'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          paiement.statut = "validé";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur validation: ${e.toString()}")),
      );
    }
  }

  Future<void> _refuserPaiement(Paiement paiement) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/admin/${paiement.id}/refuser'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          paiement.statut = "refusé";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur refus: ${e.toString()}")),
      );
    }
  }

  void _showZoomableImage(String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image zoom",
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    InteractiveViewer(
                      child: Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            Center(
                              child: Text(
                                "⚠️ Erreur de chargement de l'image",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "إدارة عمليات الدفع",
          imagePath: "assets/image300.png",
          textColor: Colors.black,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : paiements.isEmpty
            ? Center(child: Text("لا توجد دفعات حالياً."))
            : RefreshIndicator(
          onRefresh: fetchPaiements,
          child: ListView.builder(
            itemCount: paiements.length,
            itemBuilder: (context, index) {
              final p = paiements[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${p.userName} (${p.userRole})",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 6),
                      Text("البريد: ${p.userEmail}"),
                      Text("الشهر: ${p.mois}"),
                      Text("الحالة: ${p.statut}"),
                      Text("تاريخ الإرسال: ${intl.DateFormat('yyyy-MM-dd – HH:mm').format(p.createdAt)}"),
                      if (p.preuvePaiement.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: GestureDetector(
                            onTap: () => _showZoomableImage(
                              '${Config.baseImageUrl}${p.preuvePaiement}',
                            ),
                            child: Image.network(
                              '${Config.baseImageUrl}${p.preuvePaiement}',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Text("⚠️ Impossible de charger l'image"),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (p.statut != "validé")
                            ElevatedButton(
                              onPressed: () => _validerPaiement(p),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text("✔️ قبول"),
                            ),
                          SizedBox(width: 8),
                          if (p.statut != "refusé")
                            ElevatedButton(
                              onPressed: () => _refuserPaiement(p),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text("❌ رفض"),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
