import 'package:json_annotation/json_annotation.dart';

part 'mark_paid_request.g.dart';

@JsonSerializable()
class MarkPaidRequest {
  final String paymentProvider;
  final String providerTransactionId;

  const MarkPaidRequest({
    required this.paymentProvider,
    required this.providerTransactionId,
  });

  factory MarkPaidRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkPaidRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MarkPaidRequestToJson(this);
}
