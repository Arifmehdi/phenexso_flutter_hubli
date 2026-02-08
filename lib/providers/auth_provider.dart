import 'package:flutter/material.dart';
import 'package:hubli/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hubli/utils/api_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    final tokenData = prefs.getString('token');
    if (userData != null && tokenData != null) {
      _user = User.fromJson(json.decode(userData));
      _token = tokenData;
      notifyListeners();
    }
  }

  Future<void> _saveUserAndToken(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userData', json.encode(user.toJson()));
    _user = user;
    _token = token;
    notifyListeners();
  }

  Future<void> _clearUserAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userData');
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final user = User.fromJson(responseData['user']);
      await _saveUserAndToken(token, user);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Registration successful. API might return token or a success message.
      // For now, we'll assume it just succeeds.
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }

  void logout() {
    _clearUserAndToken();
  }
}
