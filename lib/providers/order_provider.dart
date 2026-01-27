import 'package:flutter/foundation.dart';
import 'package:hubli/models/cart_item.dart';
import 'package:hubli/models/order.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  void addOrder(
    List<CartItem> cartProducts,
    double total,
    String fullName,
    String addressLine1,
    String addressLine2,
    String city,
    String postalCode,
    String country,
  ) {
    _orders.insert(
      0,
      Order(
        id: DateTime.now().toString(),
        totalAmount: total,
        products: cartProducts,
        orderDate: DateTime.now(),
        fullName: fullName,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        postalCode: postalCode,
        country: country,
      ),
    );
    notifyListeners();
  }
}
