import 'package:hubli/models/cart_item.dart';

class Order {
  final String id;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime orderDate;
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String postalCode;
  final String country;

  Order({
    required this.id,
    required this.totalAmount,
    required this.products,
    required this.orderDate,
    required this.fullName,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.postalCode,
    required this.country,
  });
}
