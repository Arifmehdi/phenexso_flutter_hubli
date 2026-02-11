import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for http requests
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider
import 'package:hubli/utils/api_constants.dart'; // Import API constants
import 'package:hubli/screens/chat_screen.dart'; // Import ChatScreen
import 'package:hubli/screens/seller_chat_users_screen.dart'; // New import for SellerChatUsersScreen
import 'dart:convert'; // Import for json.decode

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({super.key});

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> {
  int _selectedIndex = 0; // Manages the selected index for BottomNavigationBar

  final List<Widget> _widgetOptions = <Widget>[
    const SellerHomeScreen(), // New: Seller Home screen (index 0)
    const AddNewProductScreen(), // (index 1)
    const SellerProductListScreen(), // (index 2)
    const OrderManagementScreen(), // (index 3)
    const SellerChatUsersScreen(), // Chat screen (index 4)
    const MoreSellerOptionsScreen(), // More options (index 5)
  ];

  void _onItemTapped(int index) {
    if (index == 0) { // If Home icon is tapped
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false); // Navigate to apps home page
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // New: Logout functionality (similar to RiderPanelScreen)
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      debugPrint('Attempting to logout from: ${ApiConstants.logoutEndpoint}');
      debugPrint('Auth Token: ${authProvider.token}');

      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}', // Include token if your API requires it
        },
      );

      debugPrint('Logout Response Status Code: ${response.statusCode}');
      debugPrint('Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Clear user data and navigate to login
        await authProvider.logout(); // This clears local data and notifies listeners
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!mounted) return;
        // Attempt to decode errorData only if response body is not empty
        String errorMessage = 'Logout failed';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body); // Assuming API returns JSON error
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Panel'),
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
                'Seller Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Sales Report'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sales Report Tapped')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support Tapped')),
                );
              },
            ),
            // New: Logout button
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
          // New: Home item
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // New Chat item
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey, // Add unselected item color for consistency
        onTap: _onItemTapped,
      ),
    );
  }
}

// New: Placeholder Screen for Seller Home
class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Seller Home Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

// Placeholder Screens for Seller Panel
class AddNewProductScreen extends StatelessWidget {
  const AddNewProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Add New Product Form', style: TextStyle(fontSize: 24)),
    );
  }
}

class SellerProductListScreen extends StatelessWidget {
  const SellerProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your Products List', style: TextStyle(fontSize: 24)),
    );
  }
}

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Manage Orders', style: TextStyle(fontSize: 24)),
    );
  }
}

class MoreSellerOptionsScreen extends StatelessWidget {
  const MoreSellerOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('More Seller Options (e.g., Sales Report, Support)', style: TextStyle(fontSize: 24)),
    );
  }
}
