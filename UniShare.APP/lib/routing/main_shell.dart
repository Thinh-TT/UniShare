import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import '../../core/network/notification_signalr_provider.dart';
import '../../features/notifications/models/notification_dto.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart'
    show unreadCountProvider;
import 'route_names.dart';

/// Root shell with bottom navigation bar for the main authenticated experience.
///
/// Subscribes to real-time notifications from [NotificationSignalRService]
/// and displays a SnackBar when a new notification arrives. Tap "Xem" on
/// the SnackBar to navigate to the notification's target screen.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  StreamSubscription<NotificationDto>? _notificationSubscription;

  static const _tabs = [
    _TabInfo(
      label: 'Trang chủ',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: RouteNames.home,
    ),
    _TabInfo(
      label: 'Tìm kiếm',
      icon: Icons.search,
      activeIcon: Icons.search,
      route: RouteNames.search,
    ),
    _TabInfo(
      label: 'Đăng bài',
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      route: RouteNames.createListing,
    ),
    _TabInfo(
      label: 'Tin nhắn',
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat,
      route: RouteNames.conversations,
    ),
    _TabInfo(
      label: 'Cá nhân',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: RouteNames.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Subscribe after first frame to ensure mounted is true and
    // all providers are available in the widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _subscribeToNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to the real-time notification stream.
  ///
  /// Each incoming notification invalidates [unreadCountProvider] so the
  /// badge updates, and shows a SnackBar with a "Xem" action that navigates
  /// to the notification's referenced screen.
  void _subscribeToNotifications() {
    final service = ref.read(notificationSignalRServiceProvider);
    _notificationSubscription = service.onNotificationReceived.listen(
      _onNotificationReceived,
      onError: (error) {
        debugPrint('[MainShell] Notification stream error: $error');
      },
    );
  }

  void _onNotificationReceived(NotificationDto notification) {
    if (!mounted) return;

    // Invalidate unread count so badges update
    ref.invalidate(unreadCountProvider);

    // Show SnackBar
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (notification.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  notification.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: notification.referenceId != null
            ? SnackBarAction(
                label: 'Xem',
                onPressed: () => _navigateToReference(notification),
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Navigate to the notification's referenced screen based on [referenceType].
  ///
  /// Reference types and their target routes:
  /// - `listing` → `/home/listings/{referenceId}`
  /// - `rentalrequest` | `review` → `/requests/{referenceId}`
  /// - `message` → `/chat/{referenceId}`
  void _navigateToReference(NotificationDto notification) {
    if (notification.referenceId == null || !mounted) return;

    try {
      switch (notification.referenceType?.toLowerCase()) {
        case 'listing':
          context.push('/home/listings/${notification.referenceId}');
        case 'rentalrequest':
        case 'review':
          context.push('/requests/${notification.referenceId}');
        case 'message':
          context.push('/chat/${notification.referenceId}');
      }
    } catch (e) {
      debugPrint('[MainShell] Navigation error: $e');
    }
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          context.go(_tabs[index].route);
        },
        items: _tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _TabInfo({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
