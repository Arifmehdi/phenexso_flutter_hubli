import 'package:flutter/material.dart';

class SellerPanelScreen extends StatelessWidget {
  const SellerPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Panel'),
      ),
      body: const Center(
        child: Text('Welcome to Seller Panel!'),
      ),
    );
  }
}
