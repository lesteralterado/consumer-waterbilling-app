import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MeterReaderApiService {
  static const String baseUrl =
      'https://anopog-waterbillingsystem-backend.onrender.com/api';

  //Upload Meter Reading with Image
  static Future<Map<String, dynamic>> uploadMeterReading({
    required int userId,
    required String readingDate,
    required double readingValue,
    required File imageFile,
  }) async {
    try {
      print('Prepare to upload meter reading...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/meter-readings/upload'),
      );

      // Add text data
      request.fields['userId'] = userId.toString();
      request.fields['reading_date'] = readingDate;
      request.fields['reading_value'] = readingValue.toString();

      // Add Image file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'meter_image',
        stream,
        length,
        filename: 'meter_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      print('Sending request to server...');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = json.decode(response.body);

      print('Response received: ${data['success']}');

      return data;
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  // Get All Meter Readings for Users
  static Future<Map<String, dynamic>> getMeterReadings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meter-readings/$userId'),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }

  // Get Latest Meter Reading
  static Future<Map<String, dynamic>> getLatestReading(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meter-readings/$userId/latest'),
      );

      // ignore: avoid_print
      print('DEBUG: Meter latest status code: ${response.statusCode}');
      // ignore: avoid_print
      print('DEBUG: Meter latest response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: Cannot connect to server - $e',
      };
    }
  }
}
