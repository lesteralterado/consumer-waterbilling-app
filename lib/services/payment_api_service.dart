import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  /// Create payment intent via backend
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'description': description,
        }),
      );

      // ignore: avoid_print
      print('DEBUG: Create payment intent status code: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Create payment intent response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Attach payment method to PayMongo intent
  static Future<Map<String, dynamic>> attachPaymentMethod({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/attach-payment-method'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'payment_intent_id': paymentIntentId,
          'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to attach payment method',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Get PayMongo payment intent status
  static Future<Map<String, dynamic>> getPaymentIntent(
      String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-intent/$paymentIntentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Pay bill via backend - marks bill as paid
  static Future<Map<String, dynamic>> payBill({
    required int billId,
    required String paymentMethod,
    required double amountPaid,
  }) async {
    try {
      print('Paying bill to backend...');

      final response = await http.post(
        Uri.parse('$baseUrl/bills/pay'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bill_id': billId,
          'payment_method': paymentMethod,
          'amount_paid': amountPaid,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Bill paid successfully',
          'data': data,
        };
      } else {
        print('Bill payment failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        try {
          final errorData = json.decode(response.body);
          print('Parsed error data: $errorData');
          return {
            'success': false,
            'message': errorData['message'] ?? 'Bill payment failed',
          };
        } catch (e) {
          print('Failed to parse error response: $e');
          return {
            'success': false,
            'message': 'Bill payment failed (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('Error paying bill: $e');
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Submit payment to backend
  /// Schema: payments (bill_id, payment_date, payment_method, amount_paid)
  static Future<Map<String, dynamic>> submitPayment({
    required int billId,
    required String paymentDate,
    required String paymentMethod,
    required double amountPaid,
  }) async {
    try {
      print('Submitting payment to backend...');

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'bill_id': billId,
          'payment_date': paymentDate,
          'payment_method': paymentMethod,
          'amount_paid': amountPaid,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Payment submitted successfully',
          'data': data,
        };
      } else {
        print('Payment submission failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        try {
          final errorData = json.decode(response.body);
          print('Parsed error data: $errorData');
          return {
            'success': false,
            'message': errorData['message'] ?? 'Payment submission failed',
          };
        } catch (e) {
          print('Failed to parse error response: $e');
          return {
            'success': false,
            'message':
                'Payment submission failed (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('Error submitting payment: $e');
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Get payment history for a specific bill
  static Future<Map<String, dynamic>> getPaymentsByBillId(int billId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/bill/$billId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payment history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Get all payments for a customer
  static Future<Map<String, dynamic>> getPaymentsByCustomerId(
      int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/customer/$customerId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payment history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  /// Get payment history for a specific user
  static Future<Map<String, dynamic>> getPaymentsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/payments/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch payment history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }
}
