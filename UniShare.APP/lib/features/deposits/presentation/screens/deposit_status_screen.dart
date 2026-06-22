import 'package:flutter/material.dart';

class DepositStatusScreen extends StatelessWidget {
  final String requestId;

  const DepositStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt cọc')),
      body: Center(
        child: Text('Deposit for: $requestId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
