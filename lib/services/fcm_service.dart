import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      // Handle foreground messages (optional - can show local notification)
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Background message handler (must be a top-level function)
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
    // Handle background messages
  }

  /// Get initial message when app is opened from terminated state
  static Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }
}
