import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPhonePermission() async {
  final status = await Permission.phone.request();
  return status.isGranted;
}

class CameraPermission {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
}