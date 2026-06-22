import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../providers/deposit_provider.dart';

class DepositStatusScreen extends ConsumerStatefulWidget {
  final String requestId;

  const DepositStatusScreen({super.key, required this.requestId});

  @override
  ConsumerState<DepositStatusScreen> createState() =>
      _DepositStatusScreenState();
}

class _DepositStatusScreenState extends ConsumerState<DepositStatusScreen> {
  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'refunded':
        return 'Đã hoàn trả';
      case 'none':
        return 'Chưa có';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '---';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu đồng';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final depositState = ref.watch(depositProvider(widget.requestId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Thông tin đặt cọc'),
      ),
      body: depositState is DepositLoading
          ? const LoadingState(message: 'Đang tải thông tin...')
          : depositState is DepositNotFound
              ? const EmptyState(
                  icon: Icons.money_off,
                  title: 'Chưa có thông tin đặt cọc',
                  subtitle:
                      'Chủ bài đăng sẽ yêu cầu đặt cọc khi bắt đầu giao dịch',
                )
              : depositState is DepositError
                  ? ErrorState(
                      message: depositState.message,
                      onRetry: () => ref
                          .read(depositProvider(widget.requestId).notifier)
                          .loadDeposit(),
                    )
                  : depositState is DepositLoaded
                      ? _buildLoaded(depositState)
                      : const LoadingState(message: 'Đang xử lý...'),
    );
  }

  Widget _buildLoaded(DepositLoaded state) {
    final deposit = state.deposit;
    final isOwner = true; // Backend will enforce permissions

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(depositProvider(widget.requestId).notifier).loadDeposit(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount hero
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _formatCurrency(deposit.amount),
                      style: const TextStyle(
                        color: AppColors.greenDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                StatusBadge.fromStatus(deposit.status.name),
                const SizedBox(height: 4),
                Text(
                  _statusLabel(deposit.status.name),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Payment info
          Text(
            'Thông tin thanh toán',
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
                    'Phương thức',
                    deposit.paymentProvider ?? '---',
                    Icons.account_balance,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Mã giao dịch',
                    deposit.providerTransactionId ?? '---',
                    Icons.receipt_long,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Ngày thanh toán',
                    _formatDate(deposit.paidAt),
                    Icons.payment,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Ngày hoàn trả',
                    _formatDate(deposit.refundedAt),
                    Icons.replay,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action error
          if (state.actionError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.actionError!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          if (deposit.status.name.toLowerCase() == 'pending' && isOwner) ...[
            AppButton(
              label: 'Đánh dấu đã thanh toán',
              variant: AppButtonVariant.primary,
              isLoading: state.isActionInProgress,
              onPressed: () => _performAction(
                () => ref
                    .read(depositProvider(widget.requestId).notifier)
                    .markPaid(deposit.id),
              ),
            ),
          ],
          if (deposit.status.name.toLowerCase() == 'paid' && isOwner) ...[
            AppButton(
              label: 'Hoàn trả cọc',
              variant: AppButtonVariant.secondary,
              isLoading: state.isActionInProgress,
              onPressed: () => _confirmRefund(deposit.id),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmRefund(String depositId) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hoàn trả cọc',
      message: 'Xác nhận hoàn trả tiền cọc? Hành động này không thể hoàn tác.',
      confirmLabel: 'Hoàn trả',
    );
    if (confirmed == true) {
      await _performAction(
        () => ref
            .read(depositProvider(widget.requestId).notifier)
            .refund(depositId),
      );
    }
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

  Widget _buildInfoRow(String label, String value, IconData? icon) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral700,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.neutral900,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
