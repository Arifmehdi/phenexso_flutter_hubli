import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:http/http.dart' as http; // Import for http requests
import 'package:hubli/utils/api_constants.dart'; // Import API constants
import 'package:hubli/screens/chat_screen.dart'; // Import ChatScreen
import 'package:hubli/screens/conversation_screen.dart'; // New import for ConversationScreen
import 'package:hubli/providers/user_provider.dart'; // Original UserProvider (for chat if needed elsewhere)
import 'package:hubli/providers/chat_provider.dart'; // New import for ChatProvider
import 'package:hubli/models/chat/user.dart'; // Original chat User model (for chat if needed elsewhere)
import 'package:hubli/providers/admin_user_provider.dart'; // New import for AdminUserProvider
import 'package:hubli/models/user.dart'; // New import for general app User model
import 'dart:convert'; // Import for json.decode
import 'package:hubli/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:hubli/screens/password_change_screen.dart'; // Import PasswordChangeScreen
import 'package:hubli/screens/contact_support_screen.dart'; // Import ContactSupportScreen

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0; // Manages the selected index for BottomNavigationBar

  final List<Widget> _widgetOptions = <Widget>[
    const AdminHomeScreen(),
    const UserManagementScreen(),
    const ProductManagementScreen(),
    const OrderManagementScreen(),
    const ChatScreen(), // Now at index 4, matching BottomNavigationBar
    const CategoryManagementScreen(), // Now at index 5
    const MoreAdminOptionsScreen(),
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

  // Logout functionality (similar to RiderPanelScreen and SellerPanelScreen)
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
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Manage Products'),
              onTap: () {
                Navigator.pop(context);
                // Navigating to the specific screen via bottom nav index or direct
                setState(() { _selectedIndex = 2; }); // Products is at index 2 in _widgetOptions
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                setState(() { _selectedIndex = 1; }); // Users is at index 1 in _widgetOptions
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Manage Orders'),
              onTap: () {
                Navigator.pop(context);
                setState(() { _selectedIndex = 3; }); // Orders is at index 3 in _widgetOptions
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                setState(() { _selectedIndex = 4; }); // Categories is at index 4 in _widgetOptions
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Contact Support'),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
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
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
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
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}

// Placeholder Screens for Admin Panel
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Encapsulating the original Admin Panel body content here
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: <Widget>[
                _buildMetricCard(context, 'Total Users', '1,234', Icons.people),
                _buildMetricCard(context, 'Total Products', '567', Icons.shopping_basket),
                _buildMetricCard(context, 'New Orders Today', '42', Icons.receipt),
                _buildMetricCard(context, 'Revenue', '\$12,345', Icons.attach_money),
              ],
            ),
          ),
        ],
      ),
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
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only fetch users if they haven't been fetched yet to avoid unnecessary calls on subsequent rebuilds
    // and if there isn't an existing error that needs to be addressed first.
    final adminUserProvider = Provider.of<AdminUserProvider>(context, listen: false);
    if (!adminUserProvider.isLoading && adminUserProvider.users.isEmpty && adminUserProvider.errorMessage == null) {
      adminUserProvider.fetchAllUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        automaticallyImplyLeading: false, // Don't show back button
      ),
      body: Consumer<AdminUserProvider>(
        builder: (context, adminUserProvider, child) {
          if (adminUserProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminUserProvider.errorMessage != null) {
            return Center(child: Text('Error: ${adminUserProvider.errorMessage}'));
          }
          if (adminUserProvider.users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: adminUserProvider.users.length,
            itemBuilder: (context, index) {
              final user = adminUserProvider.users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
                  ),
                  title: Text(user.name),
                  subtitle: Text('${user.email} - Role: ${user.role.name}, Admin: ${user.is_admin ? 'Yes' : 'No'}'),
                  // Removed chat icon and functionality
                  onTap: () {
                    // TODO: Implement user detail view or other actions
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${user.name}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Product Management Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Order Management Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Category Management Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class MoreAdminOptionsScreen extends StatelessWidget {
  const MoreAdminOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('More Admin Options (e.g., Settings, Reports)', style: TextStyle(fontSize: 24)),
    );
  }
}