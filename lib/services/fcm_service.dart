import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'issue_reporting_api_service.dart';

class FCMService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Stream for new FCM messages
  static final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageController.stream;

  /// Request FCM permission and get device token
  static Future<String?> getDeviceToken() async {
    try {
      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the device token
        String? token = await _firebaseMessaging.getToken();
        return token;
      } else {
        print('FCM permission denied');
        return null;
      }
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Register device token with backend
  static Future<bool> registerDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register-device-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'deviceToken': deviceToken,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('Device token registered successfully');
        return true;
      } else {
        print('Failed to register device token: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('Error registering device token: $e');
      return false;
    }
  }

  /// Initialize FCM and set up message handlers
  static Future<void> initializeFCM() async {
    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received foreground message: ${message.notification?.title}');
      // Save the message to SharedPreferences and emit to stream
      final savedMessage = await _saveFCMMessage(message);
      _messageController.add(savedMessage);
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Save FCM message to SharedPreferences
  static Future<Map<String, dynamic>> _saveFCMMessage(
      RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('fcm_notifications') ?? [];

    Map<String, dynamic> notification;

    if (message.data['type'] == 'issue_update') {
      // Handle issue update
      final issueId = message.data['issueId'];
      if (issueId != null) {
        // Fetch issue details (assuming GET /issues/:id exists, but service has getIssueReports)
        // For now, create notification from data
        notification = {
          'id': int.tryParse(issueId.toString()) ??
              DateTime.now().millisecondsSinceEpoch,
          'sender': 'Anopog Service',
          'subject': 'Issue Report Update',
          'preview':
              message.data['description'] ?? message.notification?.body ?? '',
          'content':
              'Issue ID: $issueId\nDescription: ${message.data['description'] ?? ''}\nFixing Date: ${message.data['fixingDate'] ?? ''}',
          'category': 'service',
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'attachments': [],
          'actions': [],
        };
      } else {
        // Fallback
        notification = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'sender': message.notification?.title ?? 'Anopog',
          'subject': message.notification?.title ?? 'Notification',
          'preview': message.notification?.body ?? '',
          'content': message.notification?.body ?? '',
          'category': 'service',
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'attachments': [],
          'actions': [],
        };
      }
    } else {
      // Regular notification
      notification = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender': message.notification?.title ?? 'Anopog',
        'subject': message.notification?.title ?? 'Notification',
        'preview': message.notification?.body ?? '',
        'content': message.notification?.body ?? '',
        'category': 'service',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
        'attachments': [],
        'actions': [],
      };
    }

    final notificationJson = json.encode(notification);
    existing.add(notificationJson);
    // Keep only last 50 messages to prevent performance issues
    if (existing.length > 50) {
      existing.removeRange(0, existing.length - 50);
    }
    await prefs.setStringList('fcm_notifications', existing);
    // Update unread count
    final currentUnread = prefs.getInt('fcm_unread_count') ?? 0;
    await prefs.setInt('fcm_unread_count', currentUnread + 1);
    return notification;
  }

  /// Background message handler (must be a top-level function)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
    // Save the message to SharedPreferences
    await _saveFCMMessage(message);
  }

  /// Get initial message when app is opened from terminated state
  static Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }
}
