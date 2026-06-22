import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../core/enums/notification_type.dart';
import '../../models/notification_dto.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).loadNotifications();
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
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(notificationsProvider.notifier)
        .loadNotifications(refresh: true);
    ref.invalidate(unreadCountProvider);
  }

  void _onTapNotification(NotificationDto notification) {
    // Mark as read
    if (!notification.isRead) {
      ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
      ref.invalidate(unreadCountProvider);
    }

    // Navigate based on reference type
    if (notification.referenceId == null) return;

    try {
      switch (notification.referenceType?.toLowerCase()) {
        case 'listing':
          context.push('/home/listings/${notification.referenceId}');
        case 'rentalrequest':
          context.push('/requests/${notification.referenceId}');
        case 'message':
          context.push('/chat/${notification.referenceId}');
        case 'review':
          context.push('/requests/${notification.referenceId}');
      }
    } catch (_) {
      // Navigation failed silently
    }
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.rentalRequest:
        return Icons.request_page;
      case NotificationType.upvote:
        return Icons.arrow_upward;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  String _relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final hasUnread = state.notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Thông báo'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
                ref.invalidate(unreadCountProvider);
              },
              child: const Text('Đã đọc tất cả'),
            ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(NotificationsState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingState(message: 'Đang tải thông báo...');
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return ErrorState(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(notificationsProvider.notifier).loadNotifications(refresh: true),
      );
    }

    if (!state.isLoading && state.notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'Không có thông báo',
        subtitle: 'Bạn sẽ nhận được thông báo khi có người tương tác',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            state.notifications.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child:
                  Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _buildNotificationItem(state.notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationDto notification) {
    return Container(
      color: notification.isRead
          ? AppColors.white
          : AppColors.greenLight.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () => _onTapNotification(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.neutral100
                      : AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(notification.type),
                  size: 20,
                  color: notification.isRead
                      ? AppColors.neutral500
                      : AppColors.greenDark,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _relativeTime(notification.createdAt),
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread dot
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
