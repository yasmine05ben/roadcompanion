import 'package:flutter_tts/flutter_tts.dart';

class VoiceInstructor {
  static final FlutterTts _flutterTts = FlutterTts();

  static Future<void> speak(String text) async {
    await _flutterTts.setLanguage("ar-SA"); // Arabic language
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  static Future<void> announceTurn(String direction) async {
    String instruction = "";

    switch (direction) {
      case "left":
        instruction = "انعطف يسارًا";
        break;
      case "right":
        instruction = "انعطف يمينًا";
        break;
      case "straight":
        instruction = "تابع سيرك للأمام";
        break;
      case "destination":
        instruction = "لقد وصلت إلى وجهتك";
        break;
      default:
        instruction = "تابع القيادة بحذر";
    }
    await speak(instruction);
  }
}
