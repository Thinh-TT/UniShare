import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    try {
      await ref.read(authProvider.notifier).login(
            _loginController.text.trim(),
            _passwordController.text,
          );
      // Redirect handled by auth state listener in splash or router
    } catch (e) {
      setState(() {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Icon(Icons.share, size: 48, color: AppColors.green),
                  const SizedBox(height: 16),
                  Text(
                    'UniShare',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Login input
                  AppInput(
                    label: 'Email / Số điện thoại',
                    hintText: 'Nhập email hoặc số điện thoại',
                    controller: _loginController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email hoặc số điện thoại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  AppInput(
                    label: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.danger),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Login button
                  AppButton(
                    label: 'Đăng nhập',
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Tạo tài khoản mới'),
                  ),

                  // Browse as guest
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Xem đồ trước',
                      style: TextStyle(color: AppColors.neutral500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
