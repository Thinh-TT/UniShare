import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/my_listings_provider.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    Future.microtask(() {
      ref.read(myListingsProvider.notifier).loadListings(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(myListingsProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(myListingsProvider.notifier).loadListings(refresh: true);
  }

  void _navigateToEdit(String listingId) {
    context.push('/profile/my-listings/listings/$listingId/edit');
  }

  Future<void> _closeListing(String listingId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đóng bài đăng',
      message: 'Bạn có chắc chắn muốn đóng bài đăng này?\nBài đăng sẽ không hiển thị trong kết quả tìm kiếm.',
      confirmLabel: 'Đóng',
    );
    if (confirmed == true && mounted) {
      final success =
          await ref.read(myListingsProvider.notifier).closeListing(listingId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đóng bài đăng')),
        );
      }
    }
  }

  Future<void> _deleteListing(String listingId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa bài đăng',
      message: 'Bạn có chắc chắn muốn xóa bài đăng này?\nHành động này không thể hoàn tác.',
      confirmLabel: 'Xóa',
      isDangerous: true,
    );
    if (confirmed == true && mounted) {
      final success =
          await ref.read(myListingsProvider.notifier).deleteListing(listingId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bài đăng')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myListingsProvider);
    final mediaBaseUrl = ref.watch(appConfigProvider).mediaBaseUrl;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Bài đăng của tôi'),
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatusChip('Tất cả', null, state.statusFilter == null),
                _buildStatusChip(
                  'Đang cho thuê',
                  ListingStatus.available,
                  state.statusFilter == ListingStatus.available,
                ),
                _buildStatusChip(
                  'Đã được đặt',
                  ListingStatus.reserved,
                  state.statusFilter == ListingStatus.reserved,
                ),
                _buildStatusChip(
                  'Đang sử dụng',
                  ListingStatus.inUse,
                  state.statusFilter == ListingStatus.inUse,
                ),
                _buildStatusChip(
                  'Đã đóng',
                  ListingStatus.closed,
                  state.statusFilter == ListingStatus.closed,
                ),
              ],
            ),
          ),

          // Listings
          Expanded(
            child: state.isLoading
                ? const LoadingState(message: 'Đang tải...')
                : state.errorMessage != null && state.listings.isEmpty
                    ? ErrorState(
                        message: state.errorMessage!,
                        onRetry: _onRefresh,
                      )
                    : state.listings.isEmpty
                        ? EmptyState(
                            icon: Icons.storefront,
                            title: 'Bạn chưa có bài đăng nào',
                            subtitle:
                                'Đăng bài ngay để chia sẻ đồ dùng của bạn',
                            actionLabel: 'Đăng bài ngay',
                            onAction: () => context.go('/post/create'),
                          )
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 16),
                              itemCount: state.listings.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= state.listings.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.green,
                                      ),
                                    ),
                                  );
                                }

                                final listing = state.listings[index];
                                final isAvailable = listing.status ==
                                    ListingStatus.available;
                                final isClosed = listing.status ==
                                    ListingStatus.closed;

                                return Column(
                                  children: [
                                    ListingCard(
                                      listing: listing,
                                      onTap: () =>
                                          _navigateToEdit(listing.id),
                                      mediaBaseUrl: mediaBaseUrl,
                                    ),
                                    // Status badge + actions
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4),
                                      child: Row(
                                        children: [
                                          StatusBadge.fromStatus(
                                              listing.status.name),
                                          const Spacer(),
                                          // Edit button (available only)
                                          if (isAvailable)
                                            _buildActionButton(
                                              icon: Icons.edit,
                                              label: 'Sửa',
                                              onTap: () =>
                                                  _navigateToEdit(
                                                      listing.id),
                                            ),
                                          // Close button (available only)
                                          if (isAvailable)
                                            _buildActionButton(
                                              icon: Icons.block,
                                              label: 'Đóng',
                                              onTap: () =>
                                                  _closeListing(
                                                      listing.id),
                                            ),
                                          // Delete button (closed only)
                                          if (isClosed)
                                            _buildActionButton(
                                              icon: Icons.delete,
                                              label: 'Xóa',
                                              isDanger: true,
                                              onTap: () =>
                                                  _deleteListing(
                                                      listing.id),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String label, ListingStatus? status, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          ref.read(myListingsProvider.notifier).setStatusFilter(status);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greenLight : AppColors.neutral100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.green : AppColors.neutral200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.greenDark : AppColors.neutral700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon,
            size: 16,
            color: isDanger ? AppColors.danger : AppColors.green),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDanger ? AppColors.danger : AppColors.green,
          ),
        ),
      ),
    );
  }
}
