// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_request_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RentalRequestSummaryDto _$RentalRequestSummaryDtoFromJson(
  Map<String, dynamic> json,
) => RentalRequestSummaryDto(
  id: json['id'] as String,
  status: json['status'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  depositAmount: (json['depositAmount'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  listingId: json['listingId'] as String,
  listingTitle: json['listingTitle'] as String,
  listingImageUrl: json['listingImageUrl'] as String?,
  otherParticipantId: json['otherParticipantId'] as String,
  otherParticipantName: json['otherParticipantName'] as String,
  otherParticipantAvatarUrl: json['otherParticipantAvatarUrl'] as String?,
  role: json['role'] as String,
);

Map<String, dynamic> _$RentalRequestSummaryDtoToJson(
  RentalRequestSummaryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'totalPrice': instance.totalPrice,
  'depositAmount': instance.depositAmount,
  'createdAt': instance.createdAt.toIso8601String(),
  'listingId': instance.listingId,
  'listingTitle': instance.listingTitle,
  'listingImageUrl': instance.listingImageUrl,
  'otherParticipantId': instance.otherParticipantId,
  'otherParticipantName': instance.otherParticipantName,
  'otherParticipantAvatarUrl': instance.otherParticipantAvatarUrl,
  'role': instance.role,
};
