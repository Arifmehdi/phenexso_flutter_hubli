import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(user?.name ?? 'Guest'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: Text(user?.email ?? ''),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

