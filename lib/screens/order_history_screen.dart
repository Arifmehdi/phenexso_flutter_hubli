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
  int _selectedIndex = 0; // Initialize to Home index

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/'); // Home
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RFQ Screen (Not Implemented)')),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart'); // Cart
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/shipping-address'); // Shipping
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Screen (Not Implemented)')),
        );
        break;
    }
  }

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
                        title: Text(
                            NumberFormat.currency(locale: 'en_BD', symbol: 'BDT ').format(order.totalAmount)),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}
