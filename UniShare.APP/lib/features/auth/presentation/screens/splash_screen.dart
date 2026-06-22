import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasChecked = false;
  bool _hasNavigated = false;
  Timer? _fallbackTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasChecked) {
      _hasChecked = true;
      // Run after the first frame so GoRouter is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  /// Safely navigate to [route], ensuring we only navigate once.
  void _navigate(String route) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();
    context.go(route);
  }

  /// Attempt to restore a previous session, then navigate accordingly.
  ///
  /// Uses a hard [Timer] fallback (5 seconds) so the user is never stuck on
  /// this screen — even if [TokenStorage] or the network hangs.
  Future<void> _checkAuth() async {
    // Hard fallback: if auth check takes > 5 seconds, go to login.
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      _navigate('/login');
    });

    try {
      await ref.read(authProvider.notifier).tryAutoLogin();
    } catch (_) {
      // [tryAutoLogin] is now defensive and always transitions state,
      // but a synchronous throw (e.g. from Riverpod setup) is still possible.
      _navigate('/login');
      return;
    }

    // Auth check completed — read the final state and navigate.
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      _navigate('/home');
    } else {
      _navigate('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Determine the message to show below the spinner.
    String message;
    if (authState is AuthInitial) {
      message =
          'Chào mừng bạn đến với UniShare!\nĐăng nhập để bắt đầu chia sẻ đồ dùng sinh viên.';
    } else {
      message = 'Đang kiểm tra phiên...';
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.share,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'UniShare',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Chia sẻ đồ dùng sinh viên',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              const LoadingState(message: ''),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
