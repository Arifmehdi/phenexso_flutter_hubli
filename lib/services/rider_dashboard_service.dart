import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/models/rider_dashboard.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class RiderDashboardService {
  final String? _token;

  RiderDashboardService(this._token);

  Future<RiderDashboard> fetchRiderDashboardData() async {
    if (_token == null) {
      throw Exception('Authentication token is missing.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/api/rider/dashboard'); // Assuming this endpoint

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      debugPrint('Rider Dashboard API Response Status: ${response.statusCode}');
      debugPrint('Rider Dashboard API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        // Assuming the API returns a direct JSON object that matches RiderDashboard structure
        // If it's nested (e.g., {'data': {...}}), adjust here.
        return RiderDashboard.fromJson(responseData);
      } else {
        String errorMessage = 'Failed to load rider dashboard data';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          debugPrint('Error decoding rider dashboard error response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Exception in RiderDashboardService: $e');
      rethrow;
    }
  }
}
