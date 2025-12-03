import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  /// Fetch user notifications from backend
  /// GET /api/user/notifications/:userId
  /// Returns up to 20 most recent notifications ordered by date descending
  static Future<Map<String, dynamic>> fetchUserNotifications({
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/notifications/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'notifications': data['notifications'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch notifications',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Mark notification as read (if backend supports this)
  /// PUT /api/user/notifications/:notificationId/read
  static Future<Map<String, dynamic>> markNotificationAsRead({
    required String notificationId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': 'Notification marked as read',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Delete notification (if backend supports this)
  /// DELETE /api/user/notifications/:notificationId
  static Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': 'Notification deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete notification',
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
