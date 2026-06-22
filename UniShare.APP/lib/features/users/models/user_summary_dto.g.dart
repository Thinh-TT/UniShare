// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSummaryDto _$UserSummaryDtoFromJson(Map<String, dynamic> json) =>
    UserSummaryDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      schoolName: json['schoolName'] as String?,
      areaName: json['areaName'] as String?,
      reputationScore: (json['reputationScore'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
    );

Map<String, dynamic> _$UserSummaryDtoToJson(UserSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'schoolName': instance.schoolName,
      'areaName': instance.areaName,
      'reputationScore': instance.reputationScore,
      'totalReviews': instance.totalReviews,
    };
