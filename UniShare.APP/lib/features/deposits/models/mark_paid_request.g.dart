// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_paid_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarkPaidRequest _$MarkPaidRequestFromJson(Map<String, dynamic> json) =>
    MarkPaidRequest(
      paymentProvider: json['paymentProvider'] as String,
      providerTransactionId: json['providerTransactionId'] as String,
    );

Map<String, dynamic> _$MarkPaidRequestToJson(MarkPaidRequest instance) =>
    <String, dynamic>{
      'paymentProvider': instance.paymentProvider,
      'providerTransactionId': instance.providerTransactionId,
    };
