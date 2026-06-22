import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../reviews/models/review_dto.dart';
import '../../reviews/models/create_review_request.dart';

/// Low-level API calls for reviews.
class ReviewsApi {
  final ApiClient _apiClient;

  ReviewsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a review for a completed rental request.
  Future<ReviewDto> createReview(
    String requestId,
    CreateReviewRequest request,
  ) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.reviews(requestId),
      data: request.toJson(),
    );
    return ReviewDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}
