import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/utils/api_constants.dart';
import 'dart:convert';

// Import buyer-relevant screens
import 'package:hubli/screens/order_history_screen.dart';
import 'package:hubli/screens/wishlist_screen.dart';
import 'package:hubli/screens/cart_screen.dart';
import 'package:hubli/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:hubli/screens/password_change_screen.dart';
import 'package:hubli/screens/contact_support_screen.dart';
// TODO: Add a BuyerDashboardProvider if specific buyer dashboard data is needed

class BuyerPanelScreen extends StatefulWidget {
  static const routeName = '/buyer-panel'; // Define routeName
  const BuyerPanelScreen({super.key});

  @override
  State<BuyerPanelScreen> createState() => _BuyerPanelScreenState();
}

class _BuyerPanelScreenState extends State<BuyerPanelScreen> {
  int _selectedIndex = 0; // Manages the selected index for BottomNavigationBar

  // Define the widgets for the main content area of the Buyer Panel
  final List<Widget> _widgetOptions = <Widget>[
    const BuyerHomeScreen(), // Index 0: Buyer's main dashboard view
    const OrderHistoryScreen(), // Index 1: Buyer's order history
    const WishlistScreen(), // Index 2: Buyer's wishlist
    const CartScreen(), // Index 3: Buyer's cart
    const ProfileEditScreen(), // Index 4: Buyer's profile edit form
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      // If Home icon is tapped in buyer panel's bottom nav, navigate to main app home
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      debugPrint('Attempting to logout from: ${ApiConstants.logoutEndpoint}');
      debugPrint('Auth Token: ${authProvider.token}');

      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      debugPrint('Logout Response Status Code: ${response.statusCode}');
      debugPrint('Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        await authProvider.logout();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!mounted) return;
        String errorMessage = 'Logout failed';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? 'Logout failed';
          } catch (e) {
            debugPrint('Error decoding logout response body: $e');
            errorMessage = 'Logout failed: Could not parse server response.';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Caught exception during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications tapped')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Buyer Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Removed 'Order History', 'Wishlist', 'My Cart', 'Chat' as they are in BottomNavigationBar
            // ListTile(
            //   leading: const Icon(Icons.history),
            //   title: const Text('Order History'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     setState(() { _selectedIndex = 1; }); // Navigate to OrderHistoryScreen
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.favorite),
            //   title: const Text('Wishlist'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     setState(() { _selectedIndex = 2; }); // Navigate to WishlistScreen
            //   },
            // ),
            // ListTile(
            //   leading: const Icon(Icons.shopping_cart),
            //   title: const Text('My Cart'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     setState(() { _selectedIndex = 3; }); // Navigate to CartScreen
            //   },
            // ),
            //  ListTile(
            //   leading: const Icon(Icons.chat),
            //   title: const Text('Chat'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     setState(() { _selectedIndex = 4; }); // Navigate to ChatScreen
            //   },
            // ),
            const Divider(), // Separator
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PasswordChangeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
                );
              },
            ),
            const Divider(), // Separator
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer before logging out
                await _logout();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Represents 'Account' or 'More' options
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

// Basic placeholder for Buyer Home Screen
class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Welcome to your Buyer Panel!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Explore products, manage orders, and more.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Basic placeholder for More Buyer Options Screen
/*
class MoreBuyerOptionsScreen extends StatelessWidget {
  const MoreBuyerOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen will likely contain direct navigation to ProfileEditScreen, PasswordChangeScreen, ContactSupportScreen
    // as well as potentially other buyer-specific settings.
    return const Center(
      child: Text('More Buyer Options Here', style: TextStyle(fontSize: 24)),
    );
  }
}
*/
