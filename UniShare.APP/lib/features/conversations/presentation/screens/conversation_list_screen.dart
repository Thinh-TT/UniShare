import 'package:flutter/material.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: const Center(
        child: Text('Tin nhắn - Phase 5', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
