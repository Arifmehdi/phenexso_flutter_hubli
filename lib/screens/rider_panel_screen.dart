import 'package:flutter/material.dart';

class RiderPanelScreen extends StatelessWidget {
  const RiderPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Panel'),
      ),
      body: const Center(
        child: Text('Welcome to Rider Panel!'),
      ),
    );
  }
}
