import 'dart:convert';
import 'package:http/http.dart' as http;

class BillingApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  // Get All Bills for User
  static Future<Map<String, dynamic>> getBills(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/billing/$userId'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  // Get Latest Bill for User
  static Future<Map<String, dynamic>> getLatestBill(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/billing/$userId/latest'),
      );

      // ignore: avoid_print
      print('DEBUG: Bill latest status code: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Bill latest response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }
}
