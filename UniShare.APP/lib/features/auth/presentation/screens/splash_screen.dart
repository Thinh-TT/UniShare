import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
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
      _checkAuth();
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo placeholder
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
            if (authState is AuthLoading)
              const LoadingState(message: 'Đang kiểm tra phiên...')
            else if (authState is! AuthInitial)
              const CircularProgressIndicator(color: AppColors.green),
          ],
        ),
      ),
    );
  }
}
