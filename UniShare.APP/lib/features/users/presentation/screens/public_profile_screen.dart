import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Center(
        child: Text('User: $userId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
