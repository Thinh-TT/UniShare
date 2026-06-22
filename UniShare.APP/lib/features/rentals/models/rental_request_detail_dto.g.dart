// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_request_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RentalRequestDetailDto _$RentalRequestDetailDtoFromJson(
  Map<String, dynamic> json,
) => RentalRequestDetailDto(
  id: json['id'] as String,
  status: json['status'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  message: json['message'] as String?,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  depositAmount: (json['depositAmount'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  listingId: json['listingId'] as String,
  listingTitle: json['listingTitle'] as String,
  listingImageUrl: json['listingImageUrl'] as String?,
  listingPricePerDay: (json['listingPricePerDay'] as num).toDouble(),
  listingType: json['listingType'] as String,
  requesterId: json['requesterId'] as String,
  requesterName: json['requesterName'] as String,
  requesterAvatarUrl: json['requesterAvatarUrl'] as String?,
  ownerId: json['ownerId'] as String,
  ownerName: json['ownerName'] as String,
  ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
  deposit: json['deposit'] == null
      ? null
      : DepositDto.fromJson(json['deposit'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RentalRequestDetailDtoToJson(
  RentalRequestDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'message': instance.message,
  'totalPrice': instance.totalPrice,
  'depositAmount': instance.depositAmount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'listingId': instance.listingId,
  'listingTitle': instance.listingTitle,
  'listingImageUrl': instance.listingImageUrl,
  'listingPricePerDay': instance.listingPricePerDay,
  'listingType': instance.listingType,
  'requesterId': instance.requesterId,
  'requesterName': instance.requesterName,
  'requesterAvatarUrl': instance.requesterAvatarUrl,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'ownerAvatarUrl': instance.ownerAvatarUrl,
  'deposit': instance.deposit,
};
