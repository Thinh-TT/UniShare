import 'package:json_annotation/json_annotation.dart';

part 'review_dto.g.dart';

/// Review DTO matching backend flat field shape.
///
/// Uses flat fields (reviewerId, reviewerName, etc.) instead of nested
/// UserSummaryDto objects to match the backend response.
@JsonSerializable()
class ReviewDto {
  final String id;
  final String rentalRequestId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final int rating;
  final String? comment;
  final double reputationDelta;
  final DateTime createdAt;

  const ReviewDto({
    required this.id,
    required this.rentalRequestId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    this.comment,
    required this.reputationDelta,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);
}
