import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:geocoding/geocoding.dart';
import '/widgets/DETAILS.dart';
import '/config.dart';



class Incident {
  final String id;
  final String userEmail;
  final String comment;
  final String photo;
  final String incidentType;
  final String subIncidentType;
  bool verified;
  String status;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  String? address;

  Incident({
    required this.id,
    required this.userEmail,
    required this.comment,
    required this.photo,
    required this.incidentType,
    required this.subIncidentType,
    required this.verified,
    required this.status,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final coordinates = location['coordinates'] ?? [0.0, 0.0];

    final lat = coordinates.length > 1 ? coordinates[1].toDouble() : 0.0;
    final lng = coordinates.length > 0 ? coordinates[0].toDouble() : 0.0;

    return Incident(
      id: json['_id'] ?? '',
      userEmail: json['userId']?['email'] ?? 'غير معروف',
      comment: json['comment'] ?? 'لا يوجد تعليق',
      photo: json['photo'] ?? '',
      incidentType: json['incidentType'] ?? 'نوع غير معروف',
      subIncidentType: json['subIncidentType'] ?? 'نوع فرعي غير معروف',
      verified: json['verified'] ?? false,
      status: json['status'] ?? "قيد الانتظار",
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      latitude: lat,
      longitude: lng,
    );
  }

}

class ManageIncidents extends StatefulWidget {
  @override
  _ManageIncidentsState createState() => _ManageIncidentsState();
}

class _ManageIncidentsState extends State<ManageIncidents> {
  List<Incident> incidents = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchIncidents();
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
      }
      return "موقع غير معروف";
    } catch (e) {
      print("Error getting address: $e");
      return "فشل في تحويل الموقع";
    }
  }

  Future<void> fetchIncidents() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/admin/gestionincidentsincidents'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 👇 Print the received data for debugging
        print("Received data from backend: $responseData");

        if (responseData['success'] == true && responseData['incidents'] is List) {
          List<Incident> loadedIncidents = [];

          for (var json in responseData['incidents']) {
            Incident incident = Incident.fromJson(json);
            if (incident.latitude != 0.0 && incident.longitude != 0.0) {
              incident.address = await getAddressFromLatLng(incident.latitude, incident.longitude);
            } else {
              incident.address = "لا يوجد موقع";
            }
            loadedIncidents.add(incident);
          }

          setState(() {
            incidents = loadedIncidents;
            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("HTTP error ${response.statusCode}");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = "⚠️ حدث خطأ أثناء تحميل الحوادث: ${error.toString()}";
      });
    }
  }


  String _getImageUrl(String photoPath) {


    if (photoPath.isEmpty) return '';
    return '${Config.baseImageUrl}/${photoPath.startsWith('/') ? photoPath.substring(1) : photoPath}';
  }

  Future<void> _verifyIncident(Incident incident) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/admin/gestionincidentsincidents/verify/${incident.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          incident.verified = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في التحقق: ${e.toString()}")),
      );
    }
  }

  Future<void> _updateStatus(Incident incident) async {
    try {
      final response = await http.patch(
        Uri.parse('${Config.baseUrl}/admin/gestionincidentsincidents/status/${incident.id}'),
        headers: {'Content-Type': 'application/json'},
        // Plus besoin d'envoyer le statut dans le body
      );
      if (response.statusCode == 200) {
        setState(() {
          incident.status = "résolu"; // Mettre à jour localement
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في تحديث الحالة: ${e.toString()}")),
      );
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ImageDialog",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1,
                        maxScale: 4,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          title: "إدارة التبليغات والتنبيهات",
          imagePath: "assets/image300.png",
          textColor: Colors.black,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: TextStyle(fontSize: 18)))
            : incidents.isEmpty
            ? Center(child: Text("لا توجد حوادث متاحة.", style: TextStyle(fontSize: 18)))
            : RefreshIndicator(
          onRefresh: fetchIncidents,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              print('✅ DEBUG: photoPath = ${incident.photo}');
              print('✅ DEBUG: full image URL = ${_getImageUrl(incident.photo)}');
              String imageUrl = _getImageUrl(incident.photo);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${incident.incidentType} - ${incident.subIncidentType}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: "البريد الإلكتروني: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: incident.userEmail),
                        ],
                      )),
                      Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: "الحالة: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: incident.status),
                        ],
                      )),
                      Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: "الموقع: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: incident.address ?? "جارٍ تحميل الموقع..."),
                        ],
                      )),
                      Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: "تاريخ الإنشاء: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: intl.DateFormat('yyyy-MM-dd – HH:mm')
                                  .format(incident.createdAt)),
                        ],
                      )),
                      if (incident.comment.isNotEmpty)
                        Text.rich(TextSpan(
                          children: [
                            TextSpan(
                                text: "تعليق: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: incident.comment),
                          ],
                        )),
                      if (incident.photo.isNotEmpty)
                        Padding(
                          padding:

                          const EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                            onTap: () =>
                                _showImageDialog(context, imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: Center(
                                        child: Text("لا يمكن تحميل الصورة")),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (incident.status != "résolu")
                            ElevatedButton(
                              onPressed: () => _updateStatus(incident), // Plus besoin de passer le statut
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: Text("✅ حل الحادث"),
                            ),
                          SizedBox(width: 8),
                          if (!incident.verified)
                            ElevatedButton(
                              onPressed: () =>
                                  _verifyIncident(incident),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                              child: Text("✔️ تحقق"),
                            ),
                        ],
                      ),
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
