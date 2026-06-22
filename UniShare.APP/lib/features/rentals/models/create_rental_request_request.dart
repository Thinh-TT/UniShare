import 'package:json_annotation/json_annotation.dart';

part 'create_rental_request_request.g.dart';

@JsonSerializable()
class CreateRentalRequestRequest {
  final DateTime startDate;
  final DateTime endDate;
  final String? message;

  const CreateRentalRequestRequest({
    required this.startDate,
    required this.endDate,
    this.message,
  });

  factory CreateRentalRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRentalRequestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRentalRequestRequestToJson(this);
}
