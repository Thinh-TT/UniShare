import 'package:flutter/material.dart';

class CreateListingScreen extends StatelessWidget {
  const CreateListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng đồ dùng')),
      body: const Center(
        child: Text('Đăng bài - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
