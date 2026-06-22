import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/app_colors.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/login_required_modal.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../conversations/presentation/providers/conversations_provider.dart'
    show conversationsRepositoryProvider;
import '../../models/listing_detail_dto.dart';
import '../../../../core/enums/listing_status.dart';
import '../../../../core/enums/listing_type.dart';
import '../providers/listings_provider.dart'
    show listingDetailProvider, listingsRepositoryProvider;

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isUpvoted = false;
  int _upvoteCount = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleUpvote() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        LoginRequiredModal.show(context);
      }
      return;
    }

    try {
      final response = await ref
          .read(listingsRepositoryProvider)
          .toggleUpvote(widget.listingId, _isUpvoted);

      if (mounted) {
        setState(() {
          _isUpvoted = response.isUpvoted;
          _upvoteCount = response.upvoteCount;
        });
      }

      // Invalidate the detail provider so other consumers refresh
      ref.invalidate(listingDetailProvider(widget.listingId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể thực hiện: $e')),
        );
      }
    }
  }

  void _showLoginRequired() {
    LoginRequiredModal.show(context);
  }

  void _navigateToComments() {
    context.push('/home/listings/${widget.listingId}/comments');
  }

  void _navigateToPublicProfile(String userId) {
    context.push('/users/$userId');
  }

  void _navigateToRentalRequest(ListingDetailDto listing) {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) {
      _showLoginRequired();
      return;
    }
    final isBorrow = listing.listingType == ListingType.borrow;
    context.push(
      '/home/listings/${widget.listingId}/request',
      extra: {
        'listingTitle': listing.title,
        'listingPricePerDay': listing.pricePerDay,
        'listingDepositAmount': listing.depositAmount,
        'listingType': isBorrow ? 'borrow' : 'rent',
      },
    );
  }

  Future<void> _navigateToChat() async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) {
      _showLoginRequired();
      return;
    }

    try {
      final repo = ref.read(conversationsRepositoryProvider);
      final conversation =
          await repo.createOrOpenConversation(widget.listingId);
      if (mounted) {
        context.push('/chat/${conversation.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể bắt đầu trò chuyện: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(listingDetailProvider(widget.listingId));
    final authState = ref.watch(authProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Chi tiết'),
      ),
      body: detailAsync.when(
        loading: () =>
            const LoadingState(message: 'Đang tải thông tin...'),
        error: (error, _) => ErrorState(
          message:
              'Không thể tải thông tin bài đăng.\n${error.toString()}',
          onRetry: () =>
              ref.invalidate(listingDetailProvider(widget.listingId)),
        ),
        data: (listing) {
          final isOwner = currentUserId == listing.owner?.id;
          final isAvailable = listing.status == ListingStatus.available;
          final isBorrow = listing.listingType == ListingType.borrow;

          // Initialize upvote state from detail data on first load.
          // We don't get per-user isUpvoted from the detail DTO, so we
          // track it locally via the toggle response.
          if (_upvoteCount == 0 && listing.upvoteCount > 0) {
            _upvoteCount = listing.upvoteCount;
          } else if (_upvoteCount == 0) {
            _upvoteCount = listing.upvoteCount;
          }

          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                        listingDetailProvider(widget.listingId));
                    await ref.read(
                        listingDetailProvider(widget.listingId).future);
                  },
                  child: ListView(
                    children: [
                      // Image carousel
                      if (listing.images != null &&
                          listing.images!.isNotEmpty) ...[
                        SizedBox(
                          height: 280,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemCount: listing.images!.length,
                                itemBuilder: (context, index) {
                                  return CachedNetworkImage(
                                    imageUrl:
                                        listing.images![index].imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.neutral100,
                                      child: const Center(
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.green,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        Container(
                                      color: AppColors.neutral100,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Dot indicators
                              if (listing.images!.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: List.generate(
                                      listing.images!.length,
                                      (index) => Container(
                                        margin: const EdgeInsets
                                            .symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index ==
                                                  _currentImageIndex
                                              ? AppColors.green
                                              : AppColors.white
                                                  .withValues(
                                                      alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Image counter
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${listing.images!.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          height: 200,
                          color: AppColors.neutral100,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 64,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                      ],

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // Title + status
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    listing.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge.fromStatus(
                                    listing.status.name),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Price + Deposit
                            Row(
                              children: [
                                Text(
                                  isBorrow
                                      ? 'Miễn phí'
                                      : '${listing.pricePerDay.toStringAsFixed(0)}đ/ngày',
                                  style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (!isBorrow &&
                                    listing.depositAmount > 0) ...[
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: AppColors.neutral200,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Cọc: ${listing.depositAmount.toStringAsFixed(0)}đ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              AppColors.neutral700,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Tags
                            if (listing.tags != null &&
                                listing.tags!.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: listing.tags!
                                    .map(
                                      (tag) => Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.neutral100,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors
                                                    .neutral500,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Description
                            Text(
                              'Mô tả',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              listing.description,
                              style:
                                  Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (listing.conditionNote != null &&
                                listing.conditionNote!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Tình trạng',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                listing.conditionNote!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Category / School / Area info
                            Row(
                              children: [
                                if (listing.category != null) ...[
                                  const Icon(Icons.category,
                                      size: 16,
                                      color: AppColors.neutral500),
                                  const SizedBox(width: 4),
                                  Text(
                                    listing.category!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              AppColors.neutral500,
                                        ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (listing.school != null) ...[
                                  const Icon(Icons.school,
                                      size: 16,
                                      color: AppColors.neutral500),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      listing.school!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors
                                                .neutral500,
                                          ),
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (listing.area != null) ...[
                                  const Icon(Icons.location_on,
                                      size: 16,
                                      color: AppColors.neutral500),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      listing.area!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors
                                                .neutral500,
                                          ),
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Owner card
                            if (listing.owner != null) ...[
                              InkWell(
                                onTap: () =>
                                    _navigateToPublicProfile(
                                        listing.owner!.id),
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        16),
                                    child: Row(
                                      children: [
                                        UserAvatar(
                                          avatarUrl: listing
                                              .owner!.avatarUrl,
                                          fullName: listing
                                              .owner!.fullName,
                                          reputationScore:
                                              listing.owner!
                                                  .reputationScore,
                                          size: 48,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                listing.owner!
                                                    .fullName,
                                                style: Theme.of(
                                                        context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(
                                                  height: 2),
                                              Text(
                                                'Uy tín: ${listing.owner!.reputationScore.toStringAsFixed(1)}',
                                                style: Theme.of(
                                                        context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .neutral500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color:
                                              AppColors.neutral200,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Stats row
                            Row(
                              children: [
                                const Icon(Icons.visibility,
                                    size: 16,
                                    color: AppColors.neutral500),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.viewCount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColors.neutral500,
                                      ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.arrow_upward,
                                    size: 16,
                                    color: AppColors.neutral500),
                                const SizedBox(width: 4),
                                Text(
                                  '$_upvoteCount',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColors.neutral500,
                                      ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 16,
                                    color: AppColors.neutral500),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.commentCount}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            AppColors.neutral500,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fixed bottom action bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Upvote button
                        _ActionIconButton(
                          icon: Icons.arrow_upward,
                          iconColor: _isUpvoted
                              ? AppColors.green
                              : AppColors.neutral700,
                          label: '$_upvoteCount',
                          onTap: _toggleUpvote,
                        ),
                        const SizedBox(width: 4),
                        // Comment button
                        _ActionIconButton(
                          icon: Icons.chat_bubble_outline,
                          label: '${listing.commentCount}',
                          onTap: _navigateToComments,
                        ),
                        const SizedBox(width: 4),
                        // Chat button (hidden for owner)
                        if (!isOwner)
                          _ActionIconButton(
                            icon: Icons.message_outlined,
                            label: 'Nhắn tin',
                            onTap: _navigateToChat,
                          ),
                        const SizedBox(width: 8),
                        // CTA: Send rental request
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: isOwner || !isAvailable
                                  ? null
                                  : () => _navigateToRentalRequest(listing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor:
                                    AppColors.disabled,
                                disabledForegroundColor:
                                    AppColors.neutral500,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isOwner
                                    ? 'Bài đăng của bạn'
                                    : !isAvailable
                                        ? 'Không khả dụng'
                                        : isBorrow
                                            ? 'Gửi yêu cầu mượn'
                                            : 'Gửi yêu cầu thuê',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Small icon + text button for the action bar.
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.neutral700),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
