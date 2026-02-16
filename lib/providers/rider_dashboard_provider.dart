import 'package:flutter/material.dart';
import 'package:hubli/models/rider_dashboard.dart';
import 'package:hubli/services/rider_dashboard_service.dart';
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider to get the token

class RiderDashboardProvider with ChangeNotifier {
  RiderDashboard? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  final RiderDashboardService _riderDashboardService;

  RiderDashboard? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RiderDashboardProvider(this._riderDashboardService); // Constructor to inject the service

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _riderDashboardService.fetchRiderDashboardData();
      // debugPrint('Fetched Rider Dashboard Data: ${_dashboardData?.toJson()}'); // Debug print
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching rider dashboard data: $_errorMessage'); // Debug print
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashboardData() {
    _dashboardData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
