import 'package:flutter/material.dart';

class RentalRequestDetailScreen extends StatelessWidget {
  final String requestId;

  const RentalRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
      body: Center(
        child: Text('Request: $requestId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
