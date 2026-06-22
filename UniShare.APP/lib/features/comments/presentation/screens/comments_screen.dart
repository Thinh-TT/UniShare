import 'package:flutter/material.dart';

class CommentsScreen extends StatelessWidget {
  final String listingId;

  const CommentsScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bình luận')),
      body: Center(
        child: Text('Comments for: $listingId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
