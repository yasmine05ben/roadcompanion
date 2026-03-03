import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NavigationService {
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    String url =
        "https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> coords = jsonDecode(response.body)["routes"][0]["geometry"]["coordinates"];
      return coords.map((c) => LatLng(c[1], c[0])).toList();
    }
    return [];
  }
}
