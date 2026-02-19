import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/utils/api_constants.dart';
import 'dart:convert';

// Import buyer-relevant screens
import 'package:hubli/screens/profile_edit_screen.dart';
import 'package:hubli/screens/password_change_screen.dart';
import 'package:hubli/screens/contact_support_screen.dart';

class BuyerPanelScreen extends StatefulWidget {
  static const routeName = '/buyer-panel';
  final Function(int)? onTabChange; // Callback to change main navigation tabs

  const BuyerPanelScreen({super.key, this.onTabChange});

  @override
  State<BuyerPanelScreen> createState() => _BuyerPanelScreenState();
}

class _BuyerPanelScreenState extends State<BuyerPanelScreen> {
  Future<void> _logout() async {
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
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        automaticallyImplyLeading: false, 
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const UserHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('My Orders & Activity'),
          _buildListTile(Icons.history, 'Order History', () {
             if (widget.onTabChange != null) {
               widget.onTabChange!(1); // Index 1 is Order History in Buyer Navigation
             }
          }),
          _buildListTile(Icons.favorite, 'My Wishlist', () {
             if (widget.onTabChange != null) {
               widget.onTabChange!(2); // Index 2 is Wishlist in Buyer Navigation
             }
          }),
          const SizedBox(height: 24),
          _buildSectionTitle('Profile Settings'),
          _buildListTile(Icons.person, 'Edit Profile', () {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileEditScreen()));
          }),
          _buildListTile(Icons.lock, 'Change Password', () {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PasswordChangeScreen()));
          }),
          const SizedBox(height: 24),
          _buildSectionTitle('Support & Help'),
          _buildListTile(Icons.support_agent, 'Contact Support', () {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactSupportScreen()));
          }),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$roleName Account',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
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
