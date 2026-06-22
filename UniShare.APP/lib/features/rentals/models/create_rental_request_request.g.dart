// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_rental_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRentalRequestRequest _$CreateRentalRequestRequestFromJson(
  Map<String, dynamic> json,
) => CreateRentalRequestRequest(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  message: json['message'] as String?,
);

Map<String, dynamic> _$CreateRentalRequestRequestToJson(
  CreateRentalRequestRequest instance,
) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'message': instance.message,
};
