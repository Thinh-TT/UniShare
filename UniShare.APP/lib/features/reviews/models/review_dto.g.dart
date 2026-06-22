// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
  id: json['id'] as String,
  rentalRequestId: json['rentalRequestId'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  reviewerAvatarUrl: json['reviewerAvatarUrl'] as String?,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  reputationDelta: (json['reputationDelta'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
  'id': instance.id,
  'rentalRequestId': instance.rentalRequestId,
  'reviewerId': instance.reviewerId,
  'reviewerName': instance.reviewerName,
  'reviewerAvatarUrl': instance.reviewerAvatarUrl,
  'rating': instance.rating,
  'comment': instance.comment,
  'reputationDelta': instance.reputationDelta,
  'createdAt': instance.createdAt.toIso8601String(),
};
