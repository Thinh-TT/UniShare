import 'package:flutter/material.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu thuê/mượn')),
      body: const Center(
        child: Text('My Requests - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
