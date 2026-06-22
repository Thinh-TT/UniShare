import 'package:flutter/material.dart';

class EditListingScreen extends StatelessWidget {
  final String listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa bài đăng')),
      body: Center(
        child: Text('Edit Listing: $listingId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
