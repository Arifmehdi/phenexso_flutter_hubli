import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for http requests
import 'package:provider/provider.dart'; // Import for AuthProvider
import 'package:hubli/providers/auth_provider.dart'; // Import AuthProvider
import 'package:hubli/utils/api_constants.dart'; // Import API constants
import 'package:hubli/screens/chat_screen.dart'; // Import ChatScreen
import 'package:hubli/screens/rider_chat_users_screen.dart'; // New import for RiderChatUsersScreen
import 'dart:convert'; // Import for json.decode
import 'package:hubli/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:hubli/screens/password_change_screen.dart'; // Import PasswordChangeScreen
import 'package:hubli/screens/contact_support_screen.dart'; // Import ContactSupportScreen
import 'package:hubli/providers/rider_dashboard_provider.dart'; // New Import
import 'package:hubli/models/rider_dashboard.dart'; // New Import
import 'package:hubli/widgets/user_header.dart'; // Common UserHeader widget

class RiderPanelScreen extends StatefulWidget {
  const RiderPanelScreen({super.key});

  @override
  State<RiderPanelScreen> createState() => _RiderPanelScreenState();
}

class _RiderPanelScreenState extends State<RiderPanelScreen> {
  int _selectedIndex = 4; // Initialized to Account (index 4)

  final List<Widget> _widgetOptions = <Widget>[
    const SizedBox.shrink(), // Index 0 is Home (navigates away)
    const ActiveOrdersScreen(), // (index 1)
    const HistoryScreen(), // (index 2)
    const RiderChatUsersScreen(), // Chat screen (index 3)
    const RiderDashboardHome(), // Dashboard (index 4)
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 4 ? 'Rider Dashboard' : 'Rider Panel'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      drawer: RiderDrawer(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account item
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey, // Ensure unselected items are visible
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class RiderDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const RiderDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  // New: Logout functionality
  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        await authProvider.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name[0].toUpperCase() ?? 'R',
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.name ?? 'Rider',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  authProvider.user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onTabChange(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delivery_dining),
            title: const Text('Active Orders'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onTabChange(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Order History'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onTabChange(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onTabChange(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Ratings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ratings Tapped')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Earnings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Earnings Tapped')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Call Support'),
            onTap: () {
              Navigator.pop(context);
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
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class RiderDashboardHome extends StatefulWidget {
  final bool isEmbedded;
  const RiderDashboardHome({super.key, this.isEmbedded = false});

  @override
  State<RiderDashboardHome> createState() => _RiderDashboardHomeState();
}

class _RiderDashboardHomeState extends State<RiderDashboardHome> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the widget initializes
    Future.microtask(() =>
        Provider.of<RiderDashboardProvider>(context, listen: false).fetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RiderDashboardProvider>(
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

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEmbedded) ...[
              const UserHeader(),
              const SizedBox(height: 24),
              const Text(
                'Rider Dashboard Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
            ],
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true, // Use shrinkWrap in GridView inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
              children: <Widget>[
                _buildMetricCard(context, 'Active Deliveries', data.activeDeliveries.toString(), Icons.delivery_dining),
                _buildMetricCard(context, 'Total Rating', '${data.averageRating.toStringAsFixed(1)} (${data.totalReviews} reviews)', Icons.star),
                _buildMetricCard(context, 'Earnings Today', '\$${data.totalEarningsToday.toStringAsFixed(2)}', Icons.money),
                _buildMetricCard(context, 'Earnings This Week', '\$${data.totalEarningsWeek.toStringAsFixed(2)}', Icons.money_outlined),
                _buildMetricCard(context, 'Earnings This Month', '\$${data.totalEarningsMonth.toStringAsFixed(2)}', Icons.currency_exchange),
                _buildMetricCard(context, 'Completed Today', data.completedDeliveriesToday.toString(), Icons.check_circle_outline),
                _buildMetricCard(context, 'Completed This Week', data.completedDeliveriesWeek.toString(), Icons.playlist_add_check),
                _buildMetricCard(context, 'Completed This Month', data.completedDeliveriesMonth.toString(), Icons.done_all),
              ],
            ),
          ],
        );

        if (widget.isEmbedded) {
          return content;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: content,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
