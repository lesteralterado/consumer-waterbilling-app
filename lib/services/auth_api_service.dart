import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final requestBody = json.encode({
        'username': username,
        'password': password,
      });

      // ignore: avoid_print
      print('DEBUG: Login request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      // ignore: avoid_print
      print('DEBUG: Login response status: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Login response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Check if user is a Consumer
        final user = data['user'];
        if (user != null &&
            user['role'] != null &&
            user['role']['name'] == 'Consumer') {
          return {
            'success': true,
            'user': user,
          };
        } else {
          return {
            'success': false,
            'message': 'Access denied. Only consumers can login.',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
