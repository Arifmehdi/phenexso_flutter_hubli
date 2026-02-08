import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for http requests
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider
import 'package:hubli/utils/api_constants.dart'; // Import API constants
import 'package:hubli/screens/chat_screen.dart'; // Import ChatScreen
import 'dart:convert'; // Import for json.decode

class RiderPanelScreen extends StatefulWidget {
  const RiderPanelScreen({super.key});

  @override
  State<RiderPanelScreen> createState() => _RiderPanelScreenState();
}

class _RiderPanelScreenState extends State<RiderPanelScreen> {
  int _selectedIndex = 0; // Manages the selected index for BottomNavigationBar

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // New: Home screen
    const ActiveOrdersScreen(),
    const HistoryScreen(),
    const MoreScreen(), // For drawer items or other secondary options (can be adjusted later)
    const ChatScreen(), // New Chat Screen
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

  // New: Logout functionality
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
        title: const Text('Rider Panel'),
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
                'Rider Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Ratings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ratings Tapped')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Earnings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Earnings Tapped')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Call Support'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call Support Tapped')),
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
            icon: Icon(Icons.delivery_dining),
            label: 'Active Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat), // New Chat item
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey, // Ensure unselected items are visible
        onTap: _onItemTapped,
      ),
    );
  }
}

// New: Placeholder Screen for Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Rider Home Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

// Placeholder Screens for Rider Panel
class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Active Orders Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Order History Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('More Options (e.g., Ratings, Earnings, Support)', style: TextStyle(fontSize: 24)),
    );
  }
}