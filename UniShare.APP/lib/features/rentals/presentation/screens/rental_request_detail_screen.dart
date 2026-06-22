import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/rental_request_detail_provider.dart';

class RentalRequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RentalRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RentalRequestDetailScreen> createState() =>
      _RentalRequestDetailScreenState();
}

class _RentalRequestDetailScreenState
    extends ConsumerState<RentalRequestDetailScreen> {
  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'accepted':
        return 'Đã chấp nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'cancelled':
        return 'Đã hủy';
      case 'inprogress':
        return 'Đang diễn ra';
      case 'completed':
        return 'Hoàn tất';
      default:
        return status;
    }
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(rentalRequestDetailProvider(widget.requestId).notifier);
    await notifier.loadDetail(
      currentUserId: (ref.read(rentalRequestDetailProvider(widget.requestId)) is RentalRequestDetailLoaded)
          ? (ref.read(rentalRequestDetailProvider(widget.requestId)) as RentalRequestDetailLoaded).currentUserId
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(rentalRequestDetailProvider(widget.requestId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Chi tiết yêu cầu'),
      ),
      body: detailState is RentalRequestDetailLoading
          ? const LoadingState(message: 'Đang tải chi tiết...')
          : detailState is RentalRequestDetailError
              ? ErrorState(
                  message: detailState.message,
                  onRetry: () => _onRefresh(),
                )
              : detailState is RentalRequestDetailLoaded
                  ? _buildLoaded(detailState)
                  : const LoadingState(message: 'Đang xử lý...'),
    );
  }

  Widget _buildLoaded(RentalRequestDetailLoaded state) {
    final request = state.request;
    final isBorrow = request.listingType.toLowerCase() == 'borrow';

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status hero section
          Center(
            child: Column(
              children: [
                StatusBadge.fromStatus(request.status),
                const SizedBox(height: 8),
                Text(
                  _statusLabel(request.status),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Listing summary card
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                context.push('/home/listings/${request.listingId}');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: AppColors.neutral100,
                        child: request.listingImageUrl != null &&
                                request.listingImageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: request.listingImageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.listingTitle,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBorrow
                                ? 'Miễn phí'
                                : '${request.listingPricePerDay.toStringAsFixed(0)}đ/ngày',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.neutral200),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Participants
          Text(
            'Người tham gia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Requester
          _buildPersonCard(
            avatarUrl: request.requesterAvatarUrl,
            name: request.requesterName,
            label: 'Người yêu cầu',
            isCurrentUser: state.isRequester,
          ),
          const SizedBox(height: 8),

          // Owner
          _buildPersonCard(
            avatarUrl: request.ownerAvatarUrl,
            name: request.ownerName,
            label: 'Chủ sở hữu',
            isCurrentUser: state.isOwner,
          ),

          const SizedBox(height: 24),

          // Date range section
          Text(
            'Thời gian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Ngày bắt đầu',
                    _formatDate(request.startDate),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Ngày kết thúc',
                    _formatDate(request.endDate),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Số ngày',
                    '${request.endDate.difference(request.startDate).inDays + 1} ngày',
                    Icons.timer_outlined,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Price breakdown
          Text(
            'Chi tiết giá',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Đơn giá',
                    isBorrow
                        ? 'Miễn phí'
                        : '${request.listingPricePerDay.toStringAsFixed(0)}đ/ngày',
                    null,
                  ),
                  const Divider(height: 16),
                  _buildInfoRow(
                    'Tổng tiền',
                    isBorrow
                        ? 'Miễn phí'
                        : '${request.totalPrice.toStringAsFixed(0)}đ',
                    null,
                    bold: true,
                    valueColor: AppColors.green,
                  ),
                  if (request.depositAmount != null &&
                      request.depositAmount! > 0) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Tiền cọc',
                      '${request.depositAmount!.toStringAsFixed(0)}đ',
                      null,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Message section
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Lời nhắn',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  request.message!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],

          // Deposit section
          if (request.deposit != null) ...[
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                context.push('/requests/${request.id}/deposit');
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: AppColors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Đặt cọc',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      StatusBadge.fromStatus(request.deposit!.status.name),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right,
                          color: AppColors.neutral200),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Action error
          if (state.actionError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.actionError!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action buttons
          ..._buildActionButtons(state),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(RentalRequestDetailLoaded state) {
    final status = state.request.status.toLowerCase();
    final buttons = <Widget>[];

    if (status == 'pending') {
      if (state.isRequester) {
        buttons.add(
          AppButton(
            label: 'Hủy yêu cầu',
            variant: AppButtonVariant.danger,
            isLoading: state.isActionInProgress,
            onPressed: () => _confirmCancel(state),
          ),
        );
      }
      if (state.isOwner) {
        buttons.add(
          AppButton(
            label: 'Chấp nhận',
            variant: AppButtonVariant.primary,
            isLoading: state.isActionInProgress,
            onPressed: () => _performAction(
              () => ref
                  .read(rentalRequestDetailProvider(widget.requestId).notifier)
                  .acceptRequest(),
            ),
          ),
        );
        buttons.add(const SizedBox(height: 8));
        buttons.add(
          AppButton(
            label: 'Từ chối',
            variant: AppButtonVariant.danger,
            isLoading: state.isActionInProgress,
            onPressed: () => _confirmReject(state),
          ),
        );
      }
    } else if (status == 'accepted') {
      if (state.isRequester) {
        buttons.add(
          AppButton(
            label: 'Hủy yêu cầu',
            variant: AppButtonVariant.danger,
            isLoading: state.isActionInProgress,
            onPressed: () => _confirmCancel(state),
          ),
        );
      }
      if (state.isOwner) {
        final depositPending = state.request.deposit != null &&
            state.request.deposit!.status.name.toLowerCase() == 'pending';
        buttons.add(
          AppButton(
            label: 'Bắt đầu giao dịch',
            variant: AppButtonVariant.primary,
            isDisabled: depositPending,
            isLoading: state.isActionInProgress,
            onPressed: depositPending
                ? null
                : () => _confirmStart(state),
          ),
        );
        if (depositPending) {
          buttons.add(const SizedBox(height: 4));
          buttons.add(
            const Text(
              'Cần thanh toán cọc trước khi bắt đầu',
              style: TextStyle(color: AppColors.warning, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }
      }
    } else if (status == 'inprogress') {
      buttons.add(
        AppButton(
          label: 'Hoàn tất giao dịch',
          variant: AppButtonVariant.secondary,
          isLoading: state.isActionInProgress,
          onPressed: () => _confirmComplete(state),
        ),
      );
    } else if (status == 'completed') {
      buttons.add(
        AppButton(
          label: 'Viết đánh giá',
          variant: AppButtonVariant.secondary,
          icon: Icons.star_outline,
          onPressed: () => _navigateToReview(state),
        ),
      );
    }

    return buttons;
  }

  Future<void> _confirmCancel(RentalRequestDetailLoaded state) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hủy yêu cầu',
      message: 'Bạn có chắc muốn hủy yêu cầu này?',
      confirmLabel: 'Hủy yêu cầu',
      isDangerous: true,
    );
    if (confirmed == true) {
      await _performAction(
        () => ref
            .read(rentalRequestDetailProvider(widget.requestId).notifier)
            .cancelRequest(),
      );
    }
  }

  Future<void> _confirmReject(RentalRequestDetailLoaded state) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Từ chối yêu cầu',
      message: 'Bạn có chắc muốn từ chối yêu cầu này?',
      confirmLabel: 'Từ chối',
      isDangerous: true,
    );
    if (confirmed == true) {
      await _performAction(
        () => ref
            .read(rentalRequestDetailProvider(widget.requestId).notifier)
            .rejectRequest(),
      );
    }
  }

  Future<void> _confirmStart(RentalRequestDetailLoaded state) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Bắt đầu giao dịch',
      message: 'Xác nhận bắt đầu giao dịch? Bài đăng sẽ chuyển sang trạng thái đang sử dụng.',
      confirmLabel: 'Bắt đầu',
    );
    if (confirmed == true) {
      await _performAction(
        () => ref
            .read(rentalRequestDetailProvider(widget.requestId).notifier)
            .startTransaction(),
      );
    }
  }

  Future<void> _confirmComplete(RentalRequestDetailLoaded state) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hoàn tất giao dịch',
      message: 'Xác nhận hoàn tất giao dịch? Sau khi hoàn tất, bạn có thể đánh giá đối phương.',
      confirmLabel: 'Hoàn tất',
    );
    if (confirmed == true) {
      await _performAction(
        () => ref
            .read(rentalRequestDetailProvider(widget.requestId).notifier)
            .completeTransaction(),
      );
    }
  }

  void _navigateToReview(RentalRequestDetailLoaded state) {
    final revieweeName = state.isRequester
        ? state.request.ownerName
        : state.request.requesterName;
    final revieweeAvatar = state.isRequester
        ? state.request.ownerAvatarUrl
        : state.request.requesterAvatarUrl;

    context.push(
      '/requests/${widget.requestId}/review',
      extra: {
        'revieweeName': revieweeName,
        'revieweeAvatarUrl': revieweeAvatar,
      },
    );
  }

  Future<void> _performAction(Future<void> Function() action) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thành công!')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Widget _buildPersonCard({
    required String? avatarUrl,
    required String name,
    required String label,
    required bool isCurrentUser,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: avatarUrl,
              fullName: name,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Bạn',
                            style: TextStyle(
                              color: AppColors.greenDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData? icon,
      {bool bold = false, Color? valueColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: AppColors.neutral700,
            fontSize: 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (bold ? AppColors.neutral900 : AppColors.neutral700),
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
