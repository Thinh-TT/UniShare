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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasChecked) {
      _hasChecked = true;
      Future.microtask(() => _checkAuth());
    }
  }

  Future<void> _checkAuth() async {
    await ref.read(authProvider.notifier).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes and redirect
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthUnauthenticated) {
        context.go('/login');
      }
    });

    // Determine the message to show below the spinner
    String message;
    if (authState is AuthInitial) {
      message = 'Chào mừng bạn đến với UniShare!\nĐăng nhập để bắt đầu chia sẻ đồ dùng sinh viên.';
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
