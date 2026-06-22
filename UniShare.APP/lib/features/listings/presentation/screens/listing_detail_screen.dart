import 'package:flutter/material.dart';

class ListingDetailScreen extends StatelessWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài đăng')),
      body: Center(
        child: Text('Listing: $listingId - Phase 5',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
