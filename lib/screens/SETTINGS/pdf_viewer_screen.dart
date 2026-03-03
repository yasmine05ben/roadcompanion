import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  const PDFViewerScreen({super.key});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final bytes = await rootBundle.load('assets/guide.pdf');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/guide.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFB),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    'دليل الاستخدام',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF277DA1),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF277DA1),
                    ),

                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
