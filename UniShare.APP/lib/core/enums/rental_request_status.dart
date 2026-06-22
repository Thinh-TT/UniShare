import 'package:json_annotation/json_annotation.dart';

/// Rental request status enum matching backend values.
enum RentalRequestStatus {
  @JsonValue('Pending')
  pending,

  @JsonValue('Accepted')
  accepted,

  @JsonValue('Rejected')
  rejected,

  @JsonValue('Cancelled')
  cancelled,

  @JsonValue('InProgress')
  inProgress,

  @JsonValue('Completed')
  completed,
}
