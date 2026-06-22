// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositDto _$DepositDtoFromJson(Map<String, dynamic> json) => DepositDto(
  id: json['id'] as String,
  rentalRequestId: json['rentalRequestId'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: $enumDecode(_$DepositStatusEnumMap, json['status']),
  paymentProvider: json['paymentProvider'] as String?,
  providerTransactionId: json['providerTransactionId'] as String?,
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  refundedAt: json['refundedAt'] == null
      ? null
      : DateTime.parse(json['refundedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DepositDtoToJson(DepositDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rentalRequestId': instance.rentalRequestId,
      'amount': instance.amount,
      'status': _$DepositStatusEnumMap[instance.status]!,
      'paymentProvider': instance.paymentProvider,
      'providerTransactionId': instance.providerTransactionId,
      'paidAt': instance.paidAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DepositStatusEnumMap = {
  DepositStatus.pending: 'Pending',
  DepositStatus.paid: 'Paid',
  DepositStatus.refunded: 'Refunded',
};
