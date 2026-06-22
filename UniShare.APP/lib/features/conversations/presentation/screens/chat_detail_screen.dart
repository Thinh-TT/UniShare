import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Text('Chat: $conversationId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
