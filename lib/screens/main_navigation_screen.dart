import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/models/user_role.dart';

import 'package:hubli/screens/product_list_screen.dart';
import 'package:hubli/screens/cart_screen.dart';
import 'package:hubli/screens/admin_panel_screen.dart';
import 'package:hubli/screens/seller_panel_screen.dart';
import 'package:hubli/screens/rider_panel_screen.dart';
import 'package:hubli/screens/buyer_panel_screen.dart';
import 'package:hubli/screens/login_screen.dart';

// Placeholder screens for other bottom nav items
class RfqScreen extends StatelessWidget {
  const RfqScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('RFQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: const Center(child: Text('RFQ Screen Content')),
    );
  }
}

class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Shipping'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
      ),
      body: const Center(child: Text('Shipping Screen Content')),
    );
  }
}

class AccountScreenWrapper extends StatelessWidget {
  const AccountScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      if (authProvider.user!.role == UserRole.admin) {
        return const AdminPanelScreen();
      } else if (authProvider.user!.role == UserRole.rider) {
        return RiderPanelScreen();
      } else if (authProvider.user!.role == UserRole.buyer || authProvider.user!.role == UserRole.user) {
        return const BuyerPanelScreen();
      } else {
        return SellerPanelScreen();
      }
    } else {
      return const LoginScreen(); // Redirect to login if not authenticated
    }
  }
}


class MainNavigationScreen extends StatefulWidget {
  static const routeName = '/'; // Set this as the initial route

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Ensure these screens handle their own AppBars if needed,
    // or MainNavigationScreen can provide a generic one.
    // For now, let's assume they have their own (like ProductListScreen does)
    const ProductListScreen(),
    const RfqScreen(),
    const CartScreen(),
    const ShippingScreen(),
    const AccountScreenWrapper(), // Use the wrapper to handle role-based redirection
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is typically managed by individual screens in a tab structure
      // or a generic one can be provided here if all tabs share the same app bar.
      // For now, we assume child screens provide their own AppBars.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) => Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          const BottomNavigationBarItem(
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
