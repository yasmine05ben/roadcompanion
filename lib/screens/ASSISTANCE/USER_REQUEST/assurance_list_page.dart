import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class AssuranceListPage extends StatelessWidget {
  AssuranceListPage({super.key});

  final List<Map<String, String>> assurances = [
    {'name': 'CAAT Assurance', 'number': '0668212302'},
    {'name': 'CAAR', 'number': '021632072'},
    {'name': 'SAA Société Nationale d\'Assurance', 'number': '021225000'},
    {'name': 'CASH Assurances', 'number': '023967007'},
    {'name': 'ALLIANCE ASSURANCE', 'number': '021697754'},
    {'name': 'TALA Assurances', 'number': '023926989'},
    {'name': 'GAM Assurances', 'number': '0982304044'},
    {'name': 'GIG ALGERIA', 'number': '0770250000'},
    {'name': 'SALAMA Assurances Algérie', 'number': '020070604'},
    {'name': 'ELDJAZAIR takaful assurance', 'number': '0541743616'},
    {'name': 'AXA Assurance', 'number': '021982300'},
    {'name': 'Caarama assurance', 'number': '023569108'},
  ];


  bool _isValidPhoneNumber(String number) {
    final regex = RegExp(r'^[0-9]+$');
    return regex.hasMatch(number);
  }

  void _makeCall(BuildContext context, String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanNumber.isEmpty || !_isValidPhoneNumber(cleanNumber)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF277DA1)),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        title: Text(
          'قائمة شركات التأمين',
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
      body: ListView.builder(
        itemCount: assurances.length,
        itemBuilder: (context, index) {
          final assurance = assurances[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                assurance['name'] ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(assurance['number'] ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.phone, color: Colors.green),
                onPressed: () =>
                    _makeCall(context, assurance['number'] ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }
}