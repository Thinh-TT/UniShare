import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Root shell with bottom navigation bar for the main authenticated experience.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

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

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // Match against top-level tab routes
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
      body: child,
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
