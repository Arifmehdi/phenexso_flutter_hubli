import 'package:flutter/material.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orderData.orders.isEmpty
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
                        title: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
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
            ),
    );
  }
}
