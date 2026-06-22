import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/reviews_api.dart';
import '../../data/reviews_repository.dart';
import '../../models/review_dto.dart';
import '../../models/create_review_request.dart';

/// Provider for ReviewsApi singleton.
final reviewsApiProvider = Provider<ReviewsApi>((ref) {
  return ReviewsApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for ReviewsRepository singleton.
final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(
    reviewsApi: ref.read(reviewsApiProvider),
  );
});

/// Sealed state for the review form.
sealed class ReviewFormState {
  const ReviewFormState();
}

class ReviewFormInitial extends ReviewFormState {
  final int rating;
  final String? comment;
  final bool isSubmitting;
  final String? error;

  const ReviewFormInitial({
    this.rating = 0,
    this.comment,
    this.isSubmitting = false,
    this.error,
  });

  ReviewFormInitial copyWith({
    int? rating,
    String? comment,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearComment = false,
  }) {
    return ReviewFormInitial(
      rating: rating ?? this.rating,
      comment: clearComment ? null : (comment ?? this.comment),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isValid => rating >= 1 && rating <= 5;
}

class ReviewFormSubmitting extends ReviewFormState {
  const ReviewFormSubmitting();
}

class ReviewFormSuccess extends ReviewFormState {
  final ReviewDto review;
  const ReviewFormSuccess(this.review);
}

class ReviewFormError extends ReviewFormState {
  final String message;
  const ReviewFormError(this.message);
}

/// Notifier for the review form.
class ReviewFormNotifier extends StateNotifier<ReviewFormState> {
  final ReviewsRepository _repository;
  final String _requestId;

  ReviewFormNotifier({
    required ReviewsRepository repository,
    required String requestId,
  })  : _repository = repository,
        _requestId = requestId,
        super(const ReviewFormInitial());

  void setRating(int rating) {
    if (state is ReviewFormInitial) {
      final s = state as ReviewFormInitial;
      state = s.copyWith(rating: rating, clearError: true);
    }
  }

  void setComment(String comment) {
    if (state is ReviewFormInitial) {
      final s = state as ReviewFormInitial;
      state = s.copyWith(
        comment: comment.isEmpty ? null : comment,
        clearComment: comment.isEmpty,
      );
    }
  }

  Future<void> submit() async {
    if (state is! ReviewFormInitial) return;
    final s = state as ReviewFormInitial;

    if (!s.isValid) {
      state = s.copyWith(error: 'Vui lòng chọn số sao đánh giá');
      return;
    }

    state = const ReviewFormSubmitting();

    try {
      final result = await _repository.createReview(
        _requestId,
        CreateReviewRequest(rating: s.rating, comment: s.comment),
      );
      state = ReviewFormSuccess(result);
    } on Exception catch (e) {
      final message = _mapError(e.toString());
      state = ReviewFormError(message);
    }
  }

  String _mapError(String error) {
    if (error.contains('409')) {
      return 'Bạn đã đánh giá giao dịch này rồi';
    }
    if (error.contains('403')) {
      return 'Chỉ có thể đánh giá sau khi giao dịch hoàn tất';
    }
    if (error.contains('400')) {
      return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    }
    return 'Không thể gửi đánh giá. Vui lòng thử lại sau.';
  }
}

/// Creates a ReviewFormNotifier.
ReviewFormNotifier createReviewFormNotifier({
  required Ref ref,
  required String requestId,
}) {
  return ReviewFormNotifier(
    repository: ref.read(reviewsRepositoryProvider),
    requestId: requestId,
  );
}
