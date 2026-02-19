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
import 'package:hubli/screens/order_history_screen.dart';
import 'package:hubli/screens/wishlist_screen.dart';

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
  final Function(int)? onTabChange;
  const AccountScreenWrapper({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    if (authProvider.user!.role == UserRole.buyer || authProvider.user!.role == UserRole.user) {
      return BuyerPanelScreen(onTabChange: onTabChange);
    }

    return const RoleDashboardLauncher();
  }
}

class RoleDashboardLauncher extends StatelessWidget {
  const RoleDashboardLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user!;
    final String roleName = user.role.toString().split('.').last.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const UserHeader(),
          const SizedBox(height: 30),
          Card(
            color: Theme.of(context).primaryColor,
            child: ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: Text('Go to $roleName Dashboard', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () {
                String route = '/';
                if (user.role == UserRole.admin) route = '/admin-panel';
                else if (user.role == UserRole.seller) route = '/seller-panel';
                else if (user.role == UserRole.rider) route = '/rider-panel';
                
                Navigator.of(context).pushNamed(route);
              },
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => authProvider.logout(),
          ),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final String roleName = user?.role.toString().split('.').last.capitalize() ?? 'User';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user?.name[0].toUpperCase() ?? 'U',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User Name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? 'user@example.com',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$roleName Account',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isBuyer = authProvider.isAuthenticated && 
        (authProvider.user!.role == UserRole.buyer || authProvider.user!.role == UserRole.user);

    // Dynamic screens based on role
    final List<Widget> screens = isBuyer 
        ? [
            const ProductListScreen(),
            const OrderHistoryScreen(),
            const WishlistScreen(),
            const CartScreen(),
            AccountScreenWrapper(onTabChange: _onItemTapped),
          ]
        : [
            const ProductListScreen(),
            const RfqScreen(),
            const CartScreen(),
            const ShippingScreen(),
            AccountScreenWrapper(onTabChange: _onItemTapped),
          ];

    // Dynamic items based on role
    final List<BottomNavigationBarItem> navItems = isBuyer
        ? [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
            _buildCartItem(),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ]
        : [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'RFQ'),
            _buildCartItem(),
            const BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Shipping'),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ];

    // Ensure _selectedIndex is within bounds if role changes
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  BottomNavigationBarItem _buildCartItem() {
    return BottomNavigationBarItem(
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
    );
  }
}
