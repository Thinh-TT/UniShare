import 'package:flutter/material.dart';

class ManageImagesScreen extends StatelessWidget {
  const ManageImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ảnh bài đăng')),
      body: const Center(
        child: Text('Manage Images - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
