import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/config.dart';
class IncidentApiService {


  static Future<bool> reportIncident({
    required String userId,
    required String incidentType,
    String? subIncidentType,
    String? comment,
    File? imageFile,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/incidents');
      final request = http.MultipartRequest('POST', uri);

      // Add required fields
      request.fields.addAll({
        'userId': userId,
        'incidentType': incidentType,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (subIncidentType != null) 'subIncidentType': subIncidentType,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });

      // Add image if provided
      if (imageFile != null) {
        final fileField = await http.MultipartFile.fromPath('photo', imageFile.path);
        request.files.add(fileField);
      }

      // Fetch auth token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ✅ DEBUG LOGGING: Show what we're about to send
      print('--- DEBUG: Preparing to send POST ---');
      print('URL: $uri');
      print('Headers: ${request.headers}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.map((f) => f.filename).toList()}');
      print('--------------------------------------');

      // Send request with timeout
      final response = await request.send().timeout(Duration(seconds: 30));

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        final errorBody = await response.stream.bytesToString();
        throw Exception('Bad request: $errorBody');
      } else if (response.statusCode == 500) {
        throw Exception('Server error, please try again later.');
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('Failed to report incident: $errorBody');
      }
    } catch (e) {
      if (e is SocketException) {
        print('No internet connection');
      } else if (e is FormatException) {
        print('Malformed response');
      } else {
        print('Incident report error: $e');
      }
      rethrow;
    }
  }
}
