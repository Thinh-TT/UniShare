import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/deposit_status.dart';

part 'deposit_dto.g.dart';

@JsonSerializable()
class DepositDto {
  final String id;
  final String rentalRequestId;
  final double amount;
  final DepositStatus status;
  final String? paymentProvider;
  final String? providerTransactionId;
  final DateTime? paidAt;
  final DateTime? refundedAt;

  const DepositDto({
    required this.id,
    required this.rentalRequestId,
    required this.amount,
    required this.status,
    this.paymentProvider,
    this.providerTransactionId,
    this.paidAt,
    this.refundedAt,
  });

  factory DepositDto.fromJson(Map<String, dynamic> json) =>
      _$DepositDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DepositDtoToJson(this);
}
