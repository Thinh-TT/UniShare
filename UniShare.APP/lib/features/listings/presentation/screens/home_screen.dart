import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UniShare')),
      body: const Center(
        child: Text('Trang chủ - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
