import 'package:json_annotation/json_annotation.dart';

part 'user_summary_dto.g.dart';

@JsonSerializable()
class UserSummaryDto {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? schoolName;
  final String? areaName;
  final double reputationScore;
  final int totalReviews;

  const UserSummaryDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.schoolName,
    this.areaName,
    required this.reputationScore,
    required this.totalReviews,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserSummaryDtoToJson(this);
}
