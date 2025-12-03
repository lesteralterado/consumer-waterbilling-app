import 'dart:convert';
import 'package:http/http.dart' as http;

class IssueReportingApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  /// Submit an issue report
  static Future<Map<String, dynamic>> submitIssueReport({
    required int userId,
    required String category,
    required String priority,
    required String description,
    required String location,
    required Map<String, bool> contactPreferences,
    List<String>? photoUrls, // Base64 encoded or URLs
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/issues'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'category': category,
          'priority': priority,
          'description': description,
          'location': location,
          'contact_sms': contactPreferences['sms'] ?? false,
          'contact_email': contactPreferences['email'] ?? false,
          'contact_push': contactPreferences['push'] ?? false,
          'photos': photoUrls ?? [],
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Issue report submitted successfully',
          'data': data,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to submit issue report',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Failed to submit issue report (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Get issue reports for a user
  static Future<Map<String, dynamic>> getIssueReports(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/issues'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final issues = data['issues'] as List<dynamic>? ?? [];
        final userIssues = issues.where((issue) {
          try {
            final uid = issue['user_id'];
            return uid != null && int.parse(uid.toString()) == userId;
          } catch (_) {
            return false;
          }
        }).toList();
        return {
          'success': true,
          'data': {'issues': userIssues},
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to fetch issue reports',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Failed to fetch issue reports (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Update an issue (admin sets fixing date)
  static Future<Map<String, dynamic>> updateIssue({
    required int issueId,
    required String fixingDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/issues/$issueId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fixing_date': fixingDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Issue updated successfully',
          'data': data,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to update issue',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Failed to update issue (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }
}
