import 'package:json_annotation/json_annotation.dart';

part 'create_review_request.g.dart';

/// Request body for creating a review.
///
/// The backend infers the reviewee from the rental request context,
/// so only rating and optional comment are needed.
@JsonSerializable()
class CreateReviewRequest {
  final int rating;
  final String? comment;

  const CreateReviewRequest({
    required this.rating,
    this.comment,
  });

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}
