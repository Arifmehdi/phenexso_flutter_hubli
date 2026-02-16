import 'package:flutter/material.dart';
import 'package:hubli/models/seller_dashboard.dart';
import 'package:hubli/services/seller_dashboard_service.dart';
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider to get the token

class SellerDashboardProvider with ChangeNotifier {
  SellerDashboard? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  final SellerDashboardService _sellerDashboardService;

  SellerDashboard? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SellerDashboardProvider(this._sellerDashboardService); // Constructor to inject the service

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _sellerDashboardService.fetchSellerDashboardData();
      // debugPrint('Fetched Seller Dashboard Data: ${_dashboardData?.toJson()}'); // Debug print
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching seller dashboard data: $_errorMessage'); // Debug print
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
