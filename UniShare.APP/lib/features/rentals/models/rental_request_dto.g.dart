// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RentalRequestDto _$RentalRequestDtoFromJson(Map<String, dynamic> json) =>
    RentalRequestDto(
      id: json['id'] as String,
      listingId: json['listingId'] as String,
      listingTitle: json['listingTitle'] as String?,
      requester: json['requester'] == null
          ? null
          : UserSummaryDto.fromJson(json['requester'] as Map<String, dynamic>),
      owner: json['owner'] == null
          ? null
          : UserSummaryDto.fromJson(json['owner'] as Map<String, dynamic>),
      status: $enumDecode(_$RentalRequestStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      depositStatus: $enumDecodeNullable(
        _$DepositStatusEnumMap,
        json['depositStatus'],
      ),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RentalRequestDtoToJson(RentalRequestDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listingId': instance.listingId,
      'listingTitle': instance.listingTitle,
      'requester': instance.requester,
      'owner': instance.owner,
      'status': _$RentalRequestStatusEnumMap[instance.status]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalPrice': instance.totalPrice,
      'depositAmount': instance.depositAmount,
      'depositStatus': _$DepositStatusEnumMap[instance.depositStatus],
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$RentalRequestStatusEnumMap = {
  RentalRequestStatus.pending: 'Pending',
  RentalRequestStatus.accepted: 'Accepted',
  RentalRequestStatus.rejected: 'Rejected',
  RentalRequestStatus.cancelled: 'Cancelled',
  RentalRequestStatus.inProgress: 'InProgress',
  RentalRequestStatus.completed: 'Completed',
};

const _$DepositStatusEnumMap = {
  DepositStatus.pending: 'Pending',
  DepositStatus.paid: 'Paid',
  DepositStatus.refunded: 'Refunded',
};
