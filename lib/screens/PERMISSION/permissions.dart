import 'package:geolocator/geolocator.dart';

class Permissions {
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }
}
