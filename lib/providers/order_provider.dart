import 'package:flutter/foundation.dart';
import 'package:hubli/models/order.dart';
import 'package:hubli/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  final OrderService _orderService;
  bool _isLoading = false;
  bool _didFetchInitialData = false;

  OrderProvider(this._orderService);

  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;
  bool get didFetchInitialData => _didFetchInitialData;

  Future<void> fetchAndSetOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> fetchedData = await _orderService.fetchOrders();
      debugPrint('OrderProvider: Mapping ${fetchedData.length} items to Order models');
      
      _orders = fetchedData.map((item) {
        try {
          return Order.fromJson(item);
        } catch (e) {
          debugPrint('OrderProvider: Error mapping individual order: $e. Item data: $item');
          return null;
        }
      })
      .where((order) => order != null)
      .cast<Order>()
      .toList();
      
      _didFetchInitialData = true;
      debugPrint('OrderProvider: Final order count in provider: ${_orders.length}');
    } catch (error) {
      debugPrint('OrderProvider: Error fetching orders: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder({
    required String name,
    required String mobile,
    String? email,
    required String addressTitle,
    required String paymentMethod,
    String? orderNote,
  }) async {
    try {
      await _orderService.placeOrder(
        name: name,
        mobile: mobile,
        email: email,
        addressTitle: addressTitle,
        paymentMethod: paymentMethod,
        orderNote: orderNote,
      );
      
      // Refresh the orders list
      await fetchAndSetOrders();
    } catch (error) {
      debugPrint('OrderProvider: Error adding order: $error');
      rethrow;
    }
  }
}
