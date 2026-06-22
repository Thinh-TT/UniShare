import 'package:flutter/material.dart';

class RentalRequestFormScreen extends StatelessWidget {
  final String listingId;

  const RentalRequestFormScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu thuê/mượn')),
      body: Center(
        child: Text('Rental request for: $listingId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
