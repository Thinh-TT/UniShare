import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: const Center(
        child: Text('Hồ sơ - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
