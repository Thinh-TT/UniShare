import 'package:json_annotation/json_annotation.dart';
import '../../users/models/user_summary_dto.dart';

part 'review_dto.g.dart';

@JsonSerializable()
class ReviewDto {
  final String id;
  final String rentalRequestId;
  final UserSummaryDto? reviewer;
  final UserSummaryDto? reviewee;
  final int rating;
  final String? comment;
  final double reputationDelta;
  final DateTime createdAt;

  const ReviewDto({
    required this.id,
    required this.rentalRequestId,
    this.reviewer,
    this.reviewee,
    required this.rating,
    this.comment,
    required this.reputationDelta,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);
}
