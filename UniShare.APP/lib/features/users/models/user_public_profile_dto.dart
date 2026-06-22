import 'package:json_annotation/json_annotation.dart';

part 'user_public_profile_dto.g.dart';

@JsonSerializable()
class UserPublicProfileDto {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? schoolName;
  final String? areaName;
  final double reputationScore;
  final int totalReviews;

  const UserPublicProfileDto({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.schoolName,
    this.areaName,
    required this.reputationScore,
    required this.totalReviews,
  });

  factory UserPublicProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserPublicProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserPublicProfileDtoToJson(this);
}
