import 'package:json_annotation/json_annotation.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class UserProfileDto {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? avatarUrl;
  final String? schoolId;
  final String? schoolName;
  final String? areaId;
  final String? areaName;
  final double reputationScore;
  final int totalReviews;
  @JsonKey(defaultValue: false)
  final bool isVerified;

  const UserProfileDto({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.avatarUrl,
    this.schoolId,
    this.schoolName,
    this.areaId,
    this.areaName,
    required this.reputationScore,
    required this.totalReviews,
    required this.isVerified,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDtoToJson(this);
}
