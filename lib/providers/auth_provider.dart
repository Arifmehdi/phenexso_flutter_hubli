import 'package:flutter/material.dart';
import 'package:hubli/models/user.dart';
import 'package:hubli/models/user_role.dart'; // Import UserRole
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/services/user_service.dart'; // Import UserService

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  late UserService _userService; // Declare UserService

  User? get user => _user;
  String? get token => _token;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initUserService(null); // Initialize UserService with no token initially
    _loadUserFromPrefs();
  }

  // Initialize UserService after token is loaded
  void _initUserService(String? token) {
    _userService = UserService(token);
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    final tokenData = prefs.getString('token');
    debugPrint('AuthProvider: _loadUserFromPrefs - userData: $userData');
    debugPrint('AuthProvider: _loadUserFromPrefs - tokenData: $tokenData');
    if (userData != null && tokenData != null) {
      _user = User.fromJson(json.decode(userData));
      _token = tokenData;
      _initUserService(_token); // Initialize UserService
      notifyListeners();
    } else {
      _initUserService(null); // Initialize UserService even if no token
    }
  }

  Future<void> _saveUserAndToken(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('AuthProvider: _saveUserAndToken - Saving token: $token');
    debugPrint('AuthProvider: _saveUserAndToken - Saving userData: ${json.encode(user.toJson())}');
    await prefs.setString('token', token);
    await prefs.setString('userData', json.encode(user.toJson()));
    _user = user;
    _token = token;
    _initUserService(_token); // Re-initialize UserService with new token
    notifyListeners();
  }

  Future<void> _clearUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    _user = null;
    _token = null;
    _initUserService(null); // Clear UserService token
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Login Response Data: $responseData'); // Debugging
      final token = responseData['token'];
      final user = User.fromJson(responseData['user']);
      print('User is_approve status: ${user.is_approve}'); // Debugging

      if (user.role != UserRole.buyer && user.is_approve != 1) {
        await _clearUserAndToken();
        throw Exception('Your account is pending admin approval. Please wait.');
      }
      await _saveUserAndToken(token, user);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }

  String _extractMessageFromMalformedJson(String malformedJson) {
    RegExp regExp = RegExp(r'(?:"message"\s*:\s*"([^"]+)"|"MESSAGE\s*"\s*"([^"]+)")', caseSensitive: false);
    Match? match = regExp.firstMatch(malformedJson);

    if (match != null) {
      return match.group(1) ?? match.group(2) ?? 'Unknown error from server.';
    }
    return 'Unknown error from server.';
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'mobile': phone,
      'password': password,
      'role': role,
    };

    print('Registering with:');
    print('URL: ${ApiConstants.registerEndpoint}');
    print('Headers: {\'Content-Type\': \'application/json\'}');
    print('Body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(ApiConstants.registerEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(requestBody),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}'); // Added to print headers
    print('Response Body: ${response.body}');


    if (response.statusCode == 200) {
      // Registration successful. API might return token or a success message.
      // For now, we'll assume it just succeeds.
    } else {
      try {
        final errorData = json.decode(response.body);
        String errorMessage = 'Registration failed';

        // Check for specific Laravel validation errors
        if (errorData is Map<String, dynamic> && errorData.containsKey('errors')) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.add('${key.capitalize()}: ${value.join(', ')}');
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } else if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }

        throw Exception(errorMessage);
      } catch (e) {
        String extractedMessage = _extractMessageFromMalformedJson(response.body);
        throw Exception('Failed to register: $extractedMessage');
      }
    }
  }

  Future<void> updateProfile(User updatedUser) async {
    if (_token == null) {
      throw Exception('User not authenticated.');
    }
    try {
      final newUserData = await _userService.updateUserProfile(updatedUser);
      await _saveUserAndToken(_token!, newUserData); // Save updated user data
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword, String confirmPassword) async {
    if (_token == null) {
      throw Exception('User not authenticated.');
    }
    try {
      await _userService.changePassword(currentPassword, newPassword, confirmPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> logout() async {
    await _clearUserAndToken();
  }
}
