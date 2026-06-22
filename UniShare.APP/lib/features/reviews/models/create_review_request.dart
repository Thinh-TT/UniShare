import 'package:json_annotation/json_annotation.dart';

part 'create_review_request.g.dart';

@JsonSerializable()
class CreateReviewRequest {
  final String revieweeId;
  final int rating;
  final String? comment;

  const CreateReviewRequest({
    required this.revieweeId,
    required this.rating,
    this.comment,
  });

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateReviewRequestToJson(this);
}
