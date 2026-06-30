import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../features/notifications/presentation/providers/notifications_provider.dart'
    show unreadCountProvider;

/// A reusable notification bell icon with a red unread count badge.
///
/// Watches [unreadCountProvider] and displays the count in a red circle
/// positioned at the top-right of the bell icon. When the count exceeds 99,
/// displays "99+".
///
/// Handles loading/error states gracefully by showing the plain icon.
class NotificationBadgeIcon extends ConsumerWidget {
  final VoidCallback? onTap;

  const NotificationBadgeIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: onTap,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
