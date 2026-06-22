import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_config.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../models/create_review_request.dart';
import '../providers/review_provider.dart'
    show reviewsRepositoryProvider;

class ReviewFormScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String? revieweeName;
  final String? revieweeAvatarUrl;

  const ReviewFormScreen({
    super.key,
    required this.requestId,
    this.revieweeName,
    this.revieweeAvatarUrl,
  });

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

enum _ReviewStatus { editing, submitting }

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen> {
  int _rating = 0;
  String? _comment;
  _ReviewStatus _status = _ReviewStatus.editing;
  String? _errorMessage;

  bool get _isValid => _rating >= 1 && _rating <= 5;

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'Tệ';
      case 2: return 'Không hài lòng';
      case 3: return 'Bình thường';
      case 4: return 'Hài lòng';
      case 5: return 'Tuyệt vời';
      default: return '';
    }
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _errorMessage = 'Vui lòng chọn số sao đánh giá');
      return;
    }

    setState(() {
      _status = _ReviewStatus.submitting;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(reviewsRepositoryProvider);
      final result = await repo.createReview(
        widget.requestId,
        CreateReviewRequest(rating: _rating, comment: _comment),
      );

      if (mounted) {
        final delta = result.reputationDelta > 0
            ? '+${result.reputationDelta}'
            : '${result.reputationDelta}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Đánh giá thành công! ($delta điểm uy tín)')),
        );
        context.pop(true);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _status = _ReviewStatus.editing;
          _errorMessage = _mapError(e.toString());
        });
      }
    }
  }

  String _mapError(String error) {
    if (error.contains('409')) return 'Bạn đã đánh giá giao dịch này rồi';
    if (error.contains('403')) return 'Chỉ có thể đánh giá sau khi giao dịch hoàn tất';
    return 'Không thể gửi đánh giá. Vui lòng thử lại sau.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Đánh giá'),
      ),
      body: _status == _ReviewStatus.submitting
          ? Stack(
              children: [
                _buildForm(),
                Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.green),
                  ),
                ),
              ],
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Reviewee info
        if (widget.revieweeName != null &&
            widget.revieweeName!.isNotEmpty) ...[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(
                    avatarUrl: widget.revieweeAvatarUrl,
                    fullName: widget.revieweeName!,
                    size: 48,
                    mediaBaseUrl: ref.read(appConfigProvider).mediaBaseUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đánh giá người dùng',
                            style: TextStyle(
                                color: AppColors.neutral500, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(widget.revieweeName!,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Rating section
        Text('Chất lượng', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () =>
                        setState(() { _rating = starIndex; _errorMessage = null; }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _rating ? Icons.star : Icons.star_border,
                        size: 48,
                        color: starIndex <= _rating
                            ? AppColors.warning
                            : AppColors.neutral200,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _rating > 0 ? _ratingLabel(_rating) : 'Chạm vào sao để đánh giá',
                style: TextStyle(
                  color: _rating > 0 ? AppColors.warning : AppColors.neutral500,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Comment input
        Text('Nhận xét (không bắt buộc)',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          maxLines: 4,
          minLines: 3,
          onChanged: (v) => _comment = v.isEmpty ? null : v,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Chia sẻ trải nghiệm của bạn...',
          ),
        ),

        // Error
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_errorMessage!,
                style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ),
        ],

        const SizedBox(height: 32),

        // Submit button
        AppButton(
          label: 'Gửi đánh giá',
          variant: AppButtonVariant.primary,
          isDisabled: !_isValid || _status == _ReviewStatus.submitting,
          onPressed: _isValid && _status != _ReviewStatus.submitting
              ? _submit
              : null,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
