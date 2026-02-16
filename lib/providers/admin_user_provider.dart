// lib/providers/admin_user_provider.dart
import 'package:flutter/material.dart';
import 'package:hubli/models/user.dart'; // General app User model
import 'package:hubli/services/admin_user_service.dart';

class AdminUserProvider with ChangeNotifier {
  final AdminUserService _adminUserService;
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _lastPage = 1;
  int _totalUsers = 0;

  AdminUserProvider(this._adminUserService);

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalUsers => _totalUsers;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchAllUsers({int page = 1}) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final responseData = await _adminUserService.fetchAllUsers(page: page);

      _users = (responseData['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      _currentPage = responseData['current_page'] ?? 1;
      _lastPage = responseData['last_page'] ?? 1;
      _totalUsers = responseData['total'] ?? 0;
      notifyListeners(); // Notify listeners after successful data update
    } catch (e) {
      _setErrorMessage(e.toString());
      _users = []; // Clear users on error
    } finally {
      _setLoading(false);
    }
  }

  void goToNextPage() {
    if (_currentPage < _lastPage) {
      fetchAllUsers(page: _currentPage + 1);
    }
  }

  void goToPreviousPage() {
    if (_currentPage > 1) {
      fetchAllUsers(page: _currentPage - 1);
    }
  }
}
