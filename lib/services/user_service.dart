// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/models/chat/user.dart'; // Reusing the chat User model

class UserService {
  final String _authToken;

  UserService(this._authToken);

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_authToken',
    };
  }

  Future<List<User>> fetchAllUsers() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/chat/users/search',
      ), // Assuming an /users endpoint
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // Assuming the API returns a list of users directly under a 'data' key or similar
      if (data['data'] != null && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid user data format');
      }
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }
}
