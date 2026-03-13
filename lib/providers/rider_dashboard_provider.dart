import 'package:flutter/material.dart';
import 'package:hubli/models/rider_dashboard.dart';
import 'package:hubli/models/order.dart';
import 'package:hubli/services/rider_dashboard_service.dart';

class RiderDashboardProvider with ChangeNotifier {
  RiderDashboard? _dashboardData;
  List<Order> _activeOrders = [];
  List<Order> _orderHistory = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  RiderDashboardService _riderDashboardService;

  RiderDashboard? get dashboardData => _dashboardData;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get orderHistory => _orderHistory;
  
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeOrders = await _riderDashboardService.fetchActiveOrders();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orderHistory = await _riderDashboardService.fetchOrderHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _riderDashboardService.updateOrderStatus(orderId, status);
      // Refresh data
      await fetchActiveOrders();
      await fetchDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearDashboardData() {
    _dashboardData = null;
    _activeOrders = [];
    _orderHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}
