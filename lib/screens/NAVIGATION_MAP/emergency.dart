import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyContactsPage extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'الدرك الوطني', 'number': '1055'},
    {'name': 'الشرطة الوطنية', 'number': '17'},
    {'name': 'الحماية المدنية / رجال الإطفاء', 'number': '1021'},
    {'name': 'الخدمة الوطنية لحرس السواحل', 'number': '1054'},
    {'name': 'سونلغاز', 'number': '3303'},
    {'name': 'إنذار الحرائق (مصلحة الغابات)', 'number': '1070'},
    {'name': 'سيال', 'number': '1594'},
    {'name': 'الجمارك', 'number': '1023'},
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Scaffold(
        backgroundColor: Color(0xFFF5F9FA),
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset('assets/return.png', width: 24, height: 24),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
          title: Text(
            'مكالمات الطوارئ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF277DA1),
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.black12,
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: contacts
                .map((contact) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_isValidPhoneNumber(contact['number']!)) {
                    _makeCall(context, contact['number']!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text('رقم الهاتف غير صالح'),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.phone, color: Colors.green),
                label: Center(
                  child: Text(
                    contact['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4ECF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                  elevation: 2,
                ),
              ),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }
// Add this function to validate phone numbers
  bool _isValidPhoneNumber(String number) {
    final regex = RegExp(r'^[0-9]+$');
    return regex.hasMatch(number);
  }

  void _makeCall(BuildContext context, String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text('رقم غير صالح'),
          ),
        ),
      );
      return;
    }

    try {
      bool? callMade = await FlutterPhoneDirectCaller.callNumber(cleanNumber);

      if (callMade == false) {
        throw 'فشل في إجراء المكالمة';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text('تعذر إجراء المكالمة: $e'),
          ),
        ),
      );
    }
  }






}
