// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_public_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPublicProfileDto _$UserPublicProfileDtoFromJson(
  Map<String, dynamic> json,
) => UserPublicProfileDto(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  schoolName: json['schoolName'] as String?,
  areaName: json['areaName'] as String?,
  reputationScore: (json['reputationScore'] as num).toDouble(),
  totalReviews: (json['totalReviews'] as num).toInt(),
);

Map<String, dynamic> _$UserPublicProfileDtoToJson(
  UserPublicProfileDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'schoolName': instance.schoolName,
  'areaName': instance.areaName,
  'reputationScore': instance.reputationScore,
  'totalReviews': instance.totalReviews,
};
