import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for http requests
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider
import 'package:hubli/utils/api_constants.dart'; // Import API constants
import 'package:hubli/screens/chat_screen.dart'; // Import ChatScreen
import 'package:hubli/screens/seller_chat_users_screen.dart'; // New import for SellerChatUsersScreen
import 'dart:convert'; // Import for json.decode
import 'package:hubli/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:hubli/screens/password_change_screen.dart'; // Import PasswordChangeScreen
import 'package:hubli/screens/contact_support_screen.dart'; // Import ContactSupportScreen
import 'package:hubli/providers/seller_dashboard_provider.dart'; // New Import
import 'package:hubli/models/seller_dashboard.dart'; // New Import

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({super.key});

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> {
  int _selectedIndex = 0; // Manages the selected index for BottomNavigationBar

  final List<Widget> _widgetOptions = <Widget>[
    SellerHomeScreen(), // Seller Home screen (index 0) - now a StatefulWidget
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
                );
              },
            ),
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

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the widget initializes
    Future.microtask(() =>
        Provider.of<SellerDashboardProvider>(context, listen: false).fetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.dashboardData == null) {
          return const Center(child: Text('No dashboard data available.'));
        }

        final data = provider.dashboardData!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seller Dashboard Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true, // Use shrinkWrap in GridView inside SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                children: <Widget>[
                  _buildMetricCard(context, 'Total Products', data.totalProducts.toString(), Icons.production_quantity_limits),
                  _buildMetricCard(context, 'Total Sales Today', '\$${data.totalSalesToday.toStringAsFixed(2)}', Icons.attach_money),
                  _buildMetricCard(context, 'Total Sales Week', '\$${data.totalSalesWeek.toStringAsFixed(2)}', Icons.money_off),
                  _buildMetricCard(context, 'Total Sales Month', '\$${data.totalSalesMonth.toStringAsFixed(2)}', Icons.payments),
                  _buildMetricCard(context, 'Pending Orders', data.totalOrdersPending.toString(), Icons.pending_actions),
                  _buildMetricCard(context, 'Shipped Orders', data.totalOrdersShipped.toString(), Icons.local_shipping),
                  _buildMetricCard(context, 'Delivered Orders', data.totalOrdersDelivered.toString(), Icons.assignment_turned_in),
                  _buildMetricCard(context, 'New Messages', data.newMessages.toString(), Icons.message),
                  _buildMetricCard(context, 'New Reviews', data.newReviews.toString(), Icons.star_rate),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
