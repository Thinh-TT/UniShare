import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/utils/image_url_resolver.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../models/rental_request_summary_dto.dart';
import '../providers/my_requests_provider.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial data
    Future.microtask(() {
      ref.read(myRequestsProvider.notifier).loadRequests();
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
      ref.read(myRequestsProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(myRequestsProvider.notifier).loadRequests(refresh: true);
  }

  void _navigateToDetail(String requestId) {
    context.push('/profile/my-requests/requests/$requestId');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Yêu cầu của tôi'),
      ),
      body: Column(
        children: [
          // Role filter segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String?>(
              segments: const [
                ButtonSegment<String?>(
                  value: null,
                  label: Text('Tất cả'),
                ),
                ButtonSegment<String?>(
                  value: 'requester',
                  label: Text('Tôi gửi'),
                ),
                ButtonSegment<String?>(
                  value: 'owner',
                  label: Text('Gửi đến tôi'),
                ),
              ],
              selected: {state.roleFilter},
              onSelectionChanged: (selected) {
                ref
                    .read(myRequestsProvider.notifier)
                    .setRoleFilter(selected.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.greenLight,
                selectedForegroundColor: AppColors.greenDark,
              ),
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatusChip(null, 'Tất cả'),
                _buildStatusChip('Pending', 'Chờ xác nhận'),
                _buildStatusChip('Accepted', 'Đã chấp nhận'),
                _buildStatusChip('Rejected', 'Đã từ chối'),
                _buildStatusChip('Cancelled', 'Đã hủy'),
                _buildStatusChip('InProgress', 'Đang diễn ra'),
                _buildStatusChip('Completed', 'Hoàn tất'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, String label) {
    final isSelected = ref.watch(myRequestsProvider).statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: isSelected,
        onSelected: (_) {
          ref.read(myRequestsProvider.notifier).setStatusFilter(status);
        },
        selectedColor: AppColors.greenLight,
        checkmarkColor: AppColors.greenDark,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.greenDark : AppColors.neutral700,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.green : AppColors.neutral200,
        ),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContent(MyRequestsState state) {
    if (state.isLoading && state.requests.isEmpty) {
      return const LoadingState(message: 'Đang tải danh sách...');
    }

    if (state.errorMessage != null && state.requests.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(myRequestsProvider.notifier).loadRequests(refresh: true),
      );
    }

    if (!state.isLoading && state.requests.isEmpty) {
      final roleText = state.roleFilter == 'owner'
          ? 'Bạn chưa nhận được yêu cầu thuê/mượn nào'
          : state.roleFilter == 'requester'
              ? 'Bạn chưa gửi yêu cầu thuê/mượn nào'
              : 'Chưa có yêu cầu thuê/mượn nào';
      return EmptyState(
        icon: Icons.request_page_outlined,
        title: roleText,
        subtitle: 'Các yêu cầu thuê/mượn sẽ hiển thị ở đây',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.requests.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.requests.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _buildRequestCard(state.requests[index]);
        },
      ),
    );
  }

  Widget _buildRequestCard(RentalRequestSummaryDto request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(request.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 64,
                  height: 64,
                  color: AppColors.neutral100,
                  child: request.listingImageUrl != null &&
                          request.listingImageUrl!.isNotEmpty
                      ? Image.network(
                          resolveImageUrl(ref.read(appConfigProvider).mediaBaseUrl, request.listingImageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image,
                            color: AppColors.neutral200,
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          color: AppColors.neutral200,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        StatusBadge.fromStatus(request.status),
                        const Spacer(),
                        Text(
                          _formatCurrency(request.totalPrice),
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Listing title
                    Text(
                      request.listingTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Counterparty + role
                    Row(
                      children: [
                        UserAvatar(
                          avatarUrl: request.otherParticipantAvatarUrl,
                          fullName: request.otherParticipantName,
                          size: 20,
                          mediaBaseUrl: ref.read(appConfigProvider).mediaBaseUrl,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            request.role == 'requester'
                                ? 'Bạn là người thuê'
                                : 'Bạn là chủ sở hữu',
                            style: const TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Date range
                    Text(
                      '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.neutral200),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}
