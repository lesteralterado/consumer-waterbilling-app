import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ReceiptApiService {
    static const String baseUrl = 'https://anopog-waterbillingsystem-backend.onrender.com/api';

    //Upload Receipt with Image
    static Future<Map<String, dynamic>> uploadReceipt({
        required int customerId,
        required double amount,
        required String paymentMethod,
        String? description,
        File? imageFile,
    }) async {
        try {
            var request = http.MultipartRequest(
                'POST',
                Uri.parse('$baseUrl/receipts/upload'),
            );

            // Add text field
            request.fields['customerId'] = customerId.toString();
            request.fields['amount'] = amount.toString();
            request.fields['paymentMethod'] = paymentMethod;
            if (description != null) {
            request.fields['description'] = description;
            }

            // Add image file if provided
            if (imageFile != null) {
                var stream = http.ByteStream(imageFile.openRead());
                var length = await imageFile.length();
                var multipartFile = http.MultipartFile(
                    'receipt_image',
                    stream,
                    length,
                    filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
                );
                request.files.add(multipartFile);
            }

            // Send request
            var streamedResponse = await request.send();
            var response = await http.Response.fromStream(streamedResponse);
            var data = json.decode(response.body);

            return data;
        } catch (e) {
            return {
                'success': false,
                'message': 'Error: Cannot connect to server - $e',
            };
        }
    }

    // Get Customer Receipts
    static Future<Map<String, dynamic>> getReceipts(int customerId) async {
        try {
            final response = await http.get(
                Uri.parse('$baseUrl/receipts/$customerId'),
            );

            return json.decode(response.body);
        } catch (e) {
            return {
                'success': false,
                'message': 'Error: Cannot connect to server - $e',
            };
        }
    }
}