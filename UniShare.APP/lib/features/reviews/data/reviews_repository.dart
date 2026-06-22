import '../../reviews/models/review_dto.dart';
import '../../reviews/models/create_review_request.dart';
import 'reviews_api.dart';

/// Business logic orchestration for reviews.
class ReviewsRepository {
  final ReviewsApi _reviewsApi;

  ReviewsRepository({required ReviewsApi reviewsApi})
      : _reviewsApi = reviewsApi;

  Future<ReviewDto> createReview(
    String requestId,
    CreateReviewRequest request,
  ) {
    return _reviewsApi.createReview(requestId, request);
  }
}
