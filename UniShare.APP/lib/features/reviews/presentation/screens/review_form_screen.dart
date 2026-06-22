import 'package:flutter/material.dart';

class ReviewFormScreen extends StatelessWidget {
  final String requestId;

  const ReviewFormScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá')),
      body: Center(
        child: Text('Review for: $requestId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
