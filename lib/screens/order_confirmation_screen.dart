import 'package:flutter/material.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final cartItem = cart.items.values.toList()[i];
                return ListTile(
                  title: Text(cartItem.product.name),
                  subtitle: Text('Quantity: ${cartItem.quantity}'),
                  trailing: Text('\$${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text(
            'Confirm Order',
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () {
            if (cart.totalAmount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart is empty. Add items to confirm order.'),
                ),
              );
              return;
            }
            // Navigate to the shipping address screen
            Navigator.of(context).pushNamed('/shipping-address');
          },
        ),
      ),
    );
  }
}