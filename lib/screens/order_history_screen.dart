import 'package:flutter/material.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);
    return orderData.orders.isEmpty
          ? const Center(
              child: Text('You have no orders yet.'),
            )
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) {
                final order = orderData.orders[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                            NumberFormat.currency(locale: 'en_BD', symbol: '৳ ').format(order.totalAmount)),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy hh:mm').format(order.orderDate),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.expand_more),
                          onPressed: () {
                            // TODO: Implement order expansion to show products
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
  }
}
