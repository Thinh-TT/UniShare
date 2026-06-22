// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileDto _$UserProfileDtoFromJson(Map<String, dynamic> json) =>
    UserProfileDto(
      id: json['id'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      schoolId: json['schoolId'] as String?,
      schoolName: json['schoolName'] as String?,
      areaId: json['areaId'] as String?,
      areaName: json['areaName'] as String?,
      reputationScore: (json['reputationScore'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      isVerified: json['isVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$UserProfileDtoToJson(UserProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'schoolId': instance.schoolId,
      'schoolName': instance.schoolName,
      'areaId': instance.areaId,
      'areaName': instance.areaName,
      'reputationScore': instance.reputationScore,
      'totalReviews': instance.totalReviews,
      'isVerified': instance.isVerified,
    };
