import 'package:flutter/material.dart';
import 'package:hubli/models/rider_dashboard.dart';
import 'package:hubli/services/rider_dashboard_service.dart';

class RiderDashboardProvider with ChangeNotifier {
  RiderDashboard? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  RiderDashboardService _riderDashboardService;

  RiderDashboard? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  RiderDashboardProvider(this._riderDashboardService);

  void updateService(RiderDashboardService newService) {
    _riderDashboardService = newService;
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _riderDashboardService.fetchRiderDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching rider dashboard data: $_errorMessage');
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
