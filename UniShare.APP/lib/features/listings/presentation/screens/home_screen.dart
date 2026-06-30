import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/widgets/listing_card.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/notification_badge_icon.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart'
    show unreadCountProvider;
import '../providers/listings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  ListingFilterParams _filters = ListingFilterParams.defaultFilter;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Set quick filters based on authenticated user's profile
    final authState = ref.read(authProvider);
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      _filters = _filters.copyWith(
        schoolId: user.schoolId,
        areaId: user.areaId,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Pagination: load next page
      final currentData = ref.read(listingsProvider(_filters));
      currentData.whenData((paged) {
        if (paged.hasMore) {
          final nextPage = paged.page + 1;
          _filters = _filters.copyWith(page: nextPage);
          ref.invalidate(listingsProvider(_filters));
        }
      });
    }
  }

  Future<void> _onRefresh() async {
    _filters = _filters.copyWith(page: 1);
    ref.invalidate(listingsProvider(_filters));
    await ref.read(listingsProvider(_filters).future);
  }

  void _navigateToDetail(String listingId) {
    context.push('/home/listings/$listingId');
  }

  void _navigateToSearch() {
    context.go('/search');
  }

  Future<void> _navigateToNotifications() async {
    await context.push('/notifications');
    if (mounted) {
      ref.invalidate(unreadCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider(_filters));
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState is AuthAuthenticated;
    final mediaBaseUrl = ref.watch(appConfigProvider).mediaBaseUrl;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('UniShare'),
        actions: [
          NotificationBadgeIcon(onTap: _navigateToNotifications),
          if (isAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => context.go('/profile'),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: _navigateToSearch,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 20, color: AppColors.neutral500),
                    const SizedBox(width: 8),
                    Text(
                      'Tìm đồ dùng...',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick filter chips (only for authenticated users who have school/area)
          if (isAuthenticated) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickChip(
                    label: 'Tất cả',
                    isSelected: true,
                    onTap: () {
                      setState(() {
                        final user =
                            (authState as AuthAuthenticated).user;
                        _filters = ListingFilterParams.defaultFilter.copyWith(
                          schoolId: user.schoolId,
                          areaId: user.areaId,
                        );
                      });
                    },
                  ),
                  if ((authState as AuthAuthenticated)
                          .user
                          .schoolName !=
                      null)
                    _buildQuickChip(
                      label:
                          '${(authState as AuthAuthenticated).user.schoolName}',
                      isSelected: _filters.schoolId != null,
                      onTap: () {
                        setState(() {
                          final user =
                              (authState as AuthAuthenticated).user;
                          if (_filters.schoolId != null) {
                            _filters = _filters.copyWith(
                              clearSchoolId: true,
                              page: 1,
                            );
                          } else {
                            _filters = _filters.copyWith(
                              schoolId: user.schoolId,
                              page: 1,
                            );
                          }
                        });
                      },
                    ),
                  if ((authState as AuthAuthenticated)
                          .user
                          .areaName !=
                      null)
                    _buildQuickChip(
                      label:
                          '${(authState as AuthAuthenticated).user.areaName}',
                      isSelected: _filters.areaId != null,
                      onTap: () {
                        setState(() {
                          final user =
                              (authState as AuthAuthenticated).user;
                          if (_filters.areaId != null) {
                            _filters = _filters.copyWith(
                              clearAreaId: true,
                              page: 1,
                            );
                          } else {
                            _filters = _filters.copyWith(
                              areaId: user.areaId,
                              page: 1,
                            );
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Listing list
          Expanded(
            child: listingsAsync.when(
              loading: () =>
                  const LoadingState(message: 'Đang tải bài đăng...'),
              error: (error, _) => ErrorState(
                message:
                    'Không thể tải danh sách bài đăng.\n${error.toString()}',
                onRetry: _onRefresh,
              ),
              data: (paged) {
                if (paged.items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.storefront,
                    title: 'Chưa có bài đăng nào',
                    subtitle: 'Hãy quay lại sau để khám phá đồ dùng mới',
                  );
                }
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    itemCount: paged.items.length + (paged.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= paged.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.green,
                            ),
                          ),
                        );
                      }

                      final listing = paged.items[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () => _navigateToDetail(listing.id),
                        mediaBaseUrl: mediaBaseUrl,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.greenLight : AppColors.neutral100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.green : AppColors.neutral200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.greenDark : AppColors.neutral700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
