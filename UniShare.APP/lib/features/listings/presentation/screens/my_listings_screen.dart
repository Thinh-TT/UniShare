import 'package:flutter/material.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài đăng của tôi')),
      body: const Center(
        child: Text('My Listings - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
