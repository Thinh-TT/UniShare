import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/notification_badge_icon.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../../models/user_profile_dto.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc chắn muốn đăng xuất?',
      confirmLabel: 'Đăng xuất',
      isDangerous: true,
    );
    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      // Navigate to login after successful logout.
      // Router redirect will confirm the unauthenticated state.
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Hồ sơ'),
        actions: [
          NotificationBadgeIcon(
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () =>
            const LoadingState(message: 'Đang tải thông tin...'),
        error: (error, _) => ErrorState(
          message: 'Không thể tải thông tin hồ sơ.\n${error.toString()}',
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) => _buildProfileContent(context, profile),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfileDto profile) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userProfileProvider);
        await ref.read(userProfileProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Header card --
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UserAvatar(
                    avatarUrl: profile.avatarUrl,
                    fullName: profile.fullName,
                    reputationScore: profile.reputationScore,
                    size: 80,
                    mediaBaseUrl: ref.read(appConfigProvider).mediaBaseUrl,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral500,
                        ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(height: 8),
                    const StatusBadge(
                      label: 'Đã xác thực',
                      color: StatusBadgeColor.success,
                    ),
                  ],
                  if (profile.schoolName != null ||
                      profile.areaName != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (profile.schoolName != null) ...[
                          const Icon(Icons.school,
                              size: 16, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile.schoolName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.neutral500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        if (profile.schoolName != null &&
                            profile.areaName != null)
                          const SizedBox(width: 16),
                        if (profile.areaName != null) ...[
                          const Icon(Icons.location_on,
                              size: 16, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile.areaName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.neutral500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Stats card --
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 20, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Text(
                              profile.reputationScore
                                  .toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uy tín',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.neutral100,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${profile.totalReviews}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đánh giá',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Menu card --
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.green),
                  title: const Text('Chỉnh sửa hồ sơ'),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.neutral200),
                  onTap: () => context.go('/profile/edit'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storefront,
                      color: AppColors.green),
                  title: const Text('Bài đăng của tôi'),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.neutral200),
                  onTap: () => context.go('/profile/my-listings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.request_page,
                      color: AppColors.green),
                  title: const Text('Yêu cầu của tôi'),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.neutral200),
                  onTap: () => context.go('/profile/my-requests'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -- Logout button --
          AppButton(
            label: 'Đăng xuất',
            onPressed: _handleLogout,
            variant: AppButtonVariant.danger,
            icon: Icons.logout,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
