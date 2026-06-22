import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa hồ sơ')),
      body: const Center(
        child: Text('Edit Profile - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
