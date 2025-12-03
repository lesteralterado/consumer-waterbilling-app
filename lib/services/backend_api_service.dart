import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendApiService {
  // Remote backend base URL
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  /// Fetch bills list and return the latest unpaid amount_due for the given userId
  static Future<Map<String, dynamic>> getLatestAmountDue(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/billing');
      final response = await http.get(uri);

      // ignore: avoid_print
      print('DEBUG: Backend bill status code: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Backend bill response body: ${response.body}');

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server returned ${response.statusCode}'
        };
      }

      final Map<String, dynamic> body = json.decode(response.body);
      final bills = body['bills'] as List<dynamic>?;
      if (bills == null || bills.isEmpty) {
        return {'success': true, 'amount_due': null};
      }

      // Filter bills for the userId and unpaid bills, then pick the latest by id
      final userBills = bills.where((b) {
        try {
          final bid = b['user_id'];
          return bid != null && int.parse(bid.toString()) == userId;
        } catch (_) {
          return false;
        }
      }).toList();

      if (userBills.isEmpty) return {'success': true, 'amount_due': null};

      userBills.sort((a, b) {
        final ai = int.tryParse(a['id'].toString()) ?? 0;
        final bi = int.tryParse(b['id'].toString()) ?? 0;
        return bi.compareTo(ai);
      });

      final latest = userBills.first;
      final amount = double.tryParse(latest['amount_due'].toString()) ??
          (latest['amount_due'] is int
              ? (latest['amount_due'] as int).toDouble()
              : null);
      final billId = int.tryParse(latest['id'].toString()) ?? 0;

      return {'success': true, 'amount_due': amount, 'bill_id': billId};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching billing: $e'};
    }
  }

  /// Fetch meter readings and return a friendly string for the latest reading for given userId
  static Future<Map<String, dynamic>> getLatestMeterReading(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/meter-readings');
      final response = await http.get(uri);

      // ignore: avoid_print
      print('DEBUG: Backend meter status code: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Backend meter response body: ${response.body}');

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Server returned ${response.statusCode}'
        };
      }

      final Map<String, dynamic> body = json.decode(response.body);
      final readings = body['meterReadings'] as List<dynamic>? ??
          body['meter_readings'] as List<dynamic>?;
      if (readings == null || readings.isEmpty)
        return {'success': true, 'reading': null};

      // Filter by user id
      final userReadings = readings.where((r) {
        try {
          final uid = r['user_id'];
          return uid != null && int.parse(uid.toString()) == userId;
        } catch (_) {
          return false;
        }
      }).toList();

      if (userReadings.isEmpty) return {'success': true, 'reading': null};

      userReadings.sort((a, b) {
        final ai = int.tryParse(a['id'].toString()) ?? 0;
        final bi = int.tryParse(b['id'].toString()) ?? 0;
        return bi.compareTo(ai);
      });

      final latest = userReadings.first;

      // Try to extract a readable value from various possible shapes
      final rv = latest['reading_value'];
      String readingString;
      if (rv == null) {
        readingString = '';
      } else if (rv is num) {
        readingString = rv.toString();
      } else if (rv is String) {
        readingString = rv;
      } else if (rv is Map) {
        // If it has 'd' which is a list of numbers, join them if plausible
        try {
          if (rv.containsKey('d') && rv['d'] is List) {
            final parts = (rv['d'] as List).map((e) => e.toString()).toList();
            readingString = parts.join('');
          } else if (rv.containsKey('value')) {
            readingString = rv['value'].toString();
          } else {
            readingString = rv.toString();
          }
        } catch (e) {
          readingString = rv.toString();
        }
      } else {
        readingString = rv.toString();
      }

      return {'success': true, 'reading': readingString};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching meter readings: $e'};
    }
  }

  /// Register FCM device token
  static Future<Map<String, dynamic>> registerDeviceToken({
    required int userId,
    required String deviceToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register-device-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'device_token': deviceToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Device token registered successfully',
          'data': data,
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['message'] ?? 'Failed to register device token',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Failed to register device token (Status: ${response.statusCode})',
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
