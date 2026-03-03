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
import 'package:hubli/providers/product_provider.dart';
import 'package:hubli/models/user.dart'; // New import for general app User model
import 'dart:convert'; // Import for json.decode
import 'package:hubli/screens/profile_edit_screen.dart'; // Import ProfileEditScreen
import 'package:hubli/screens/password_change_screen.dart'; // Import PasswordChangeScreen
import 'package:hubli/screens/contact_support_screen.dart'; // Import ContactSupportScreen
import 'package:hubli/widgets/user_header.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 5; // Default to Dashboard (index 5)

  final List<Widget> _widgetOptions = <Widget>[
    const SizedBox.shrink(), // Index 0: Home (navigates away)
    const UserManagementScreen(),
    const ProductManagementScreen(),
    const OrderManagementScreen(),
    const ChatScreen(),
    const AdminHomeScreen(), // Index 5: Dashboard
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 5 ? 'Admin Dashboard' : 'Admin Panel'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

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
        children: [
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
                    authProvider.user?.name[0].toUpperCase() ?? 'A',
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.name ?? 'Admin',
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
            selected: selectedIndex == 5,
            onTap: () {
              Navigator.pop(context);
              onTabChange(5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onTabChange(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Manage Products'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onTabChange(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Manage Orders'),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onTabChange(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onTabChange(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PasswordChangeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactSupportScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  final bool isEmbedded;
  const AdminHomeScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEmbedded) ...[
          const UserHeader(),
          const SizedBox(height: 24),
        ],
        const Text(
          'Admin Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
      ],
    );

    if (isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: content,
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
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final adminUserProvider = Provider.of<AdminUserProvider>(context, listen: false);
    if (!adminUserProvider.isLoading && adminUserProvider.users.isEmpty && adminUserProvider.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adminUserProvider.fetchAllUsers(page: 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AdminUserProvider>(
        builder: (context, adminUserProvider, child) {
          if (adminUserProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminUserProvider.errorMessage != null) {
            return Center(child: Text('Error: ${adminUserProvider.errorMessage}'));
          }
          if (adminUserProvider.users.isEmpty && adminUserProvider.currentPage == 0) {
            return const Center(child: Text('No users found.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                        subtitle: Text('${user.email} - Role: ${user.role?.name ?? 'N/A'}'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tapped on ${user.name}')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: adminUserProvider.currentPage > 1
                          ? () => adminUserProvider.goToPreviousPage()
                          : null,
                      child: const Text('Previous'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Page ${adminUserProvider.currentPage} of ${adminUserProvider.lastPage}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: adminUserProvider.currentPage < adminUserProvider.lastPage
                          ? () => adminUserProvider.goToNextPage()
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(clearProducts: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: Text('Error: ${provider.errorMessage}'));
        }
        if (provider.products.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: product.imageUrls.isNotEmpty && !product.imageUrls[0].contains('placeholder')
                          ? Image.network(product.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                          : const Icon(Icons.image, size: 50),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: ৳${product.price.toStringAsFixed(2)}'),
                          Text('Stock: ${product.stock}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit ${product.name}')));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete ${product.name}')));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (provider.hasMore)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: provider.isFetchingMore
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => provider.fetchNextPage(),
                        child: const Text('Load More'),
                      ),
              ),
          ],
        );
      },
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
