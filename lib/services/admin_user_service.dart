// lib/services/admin_user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/models/user.dart'; // General app User model

class AdminUserService {
  final String _authToken;

  AdminUserService(this._authToken);

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  Future<List<User>> fetchAllUsers() async {
    // Assuming a general endpoint for fetching all app users
    // If this endpoint is incorrect, the user needs to provide the correct one.
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users'),
      headers: _getHeaders(),
    );

    debugPrint('AdminUserService - API Response Status Code: ${response.statusCode}');
    debugPrint('AdminUserService - API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Assuming the API returns a list of users directly under a 'users' key or similar
      // The backend may return 'data' or 'items' or directly a list. Adjust as needed.
      if (data['users'] != null && data['users'] is List) {
        return (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid general user data format: Missing or invalid "users" key.');
      }
    } else {
      throw Exception('Failed to load general users: ${response.statusCode}');
    }
  }
}
