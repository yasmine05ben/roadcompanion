import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF277DA1);
const Color borderColor = Color(0xFFB9D3E1);
const Color backgroundColor = Color(0xFFFFFFFB);
const Color fieldFillColor = Color(0xFFF7FDFF);

class EditFieldScreen extends StatefulWidget {
  final String fieldLabel;
  final String initialValue;
  final Function(String) onSave;

  const EditFieldScreen({
    Key? key,
    required this.fieldLabel,
    required this.initialValue,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isPhoneNumberValid(String phone) {
    final RegExp phoneRegex = RegExp(r'^(05|06|07)\d{8}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF8F5FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.red,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'رجوع',
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF8F5FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'تم التحديث بنجاح',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: primaryColor,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'تم حفظ التغييرات بنجاح.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'موافق',
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveField() async {
    final newValue = _controller.text.trim();
    final originalValue = widget.initialValue.trim();
    final label = widget.fieldLabel;

    if (newValue.isEmpty) {
      await _showErrorDialog('خطأ', 'لا يمكن ترك الحقل فارغاً');
      return;
    }

    if (newValue == originalValue) {
      await _showErrorDialog('خطأ', 'لم تقم بأي تغيير');
      return;
    }

    if (label.contains('بريد') && !_isEmailValid(newValue)) {
      await _showErrorDialog('خطأ', 'صيغة البريد الإلكتروني غير صحيحة');
      return;
    }

    if (label.contains('هاتف') && !_isPhoneNumberValid(newValue)) {
      await _showErrorDialog('خطأ', 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 05 أو 06 أو 07 ويحتوي على 10 أرقام)');
      return;
    }

    // ✅ Passed all checks
    widget.onSave(newValue);

    // Show success dialog after saving
    await _showSuccessDialog();

    // After user clicks "موافق", pop the screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'تعديل الحقل',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: primaryColor,
                        size: 30,
                      ),
                      onPressed: _saveField,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: primaryColor,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.fieldLabel,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: fieldFillColor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'املأ الحقل لتحديث البيانات.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
