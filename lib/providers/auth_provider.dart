import 'package:flutter/material.dart';
import 'package:hubli/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  void login(String email, String password) {
    // In a real app, you would authenticate with a backend.
    // For now, we'll just create a dummy user.
    _user = User(id: '1', name: 'John Doe', email: email);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
