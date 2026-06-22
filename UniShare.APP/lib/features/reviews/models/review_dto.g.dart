// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
  id: json['id'] as String,
  rentalRequestId: json['rentalRequestId'] as String,
  reviewer: json['reviewer'] == null
      ? null
      : UserSummaryDto.fromJson(json['reviewer'] as Map<String, dynamic>),
  reviewee: json['reviewee'] == null
      ? null
      : UserSummaryDto.fromJson(json['reviewee'] as Map<String, dynamic>),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  reputationDelta: (json['reputationDelta'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
  'id': instance.id,
  'rentalRequestId': instance.rentalRequestId,
  'reviewer': instance.reviewer,
  'reviewee': instance.reviewee,
  'rating': instance.rating,
  'comment': instance.comment,
  'reputationDelta': instance.reputationDelta,
  'createdAt': instance.createdAt.toIso8601String(),
};
