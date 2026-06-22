import 'package:json_annotation/json_annotation.dart';

/// Deposit status enum matching backend values.
enum DepositStatus {
  @JsonValue('Pending')
  pending,

  @JsonValue('Paid')
  paid,

  @JsonValue('Refunded')
  refunded,
}
