import 'package:json_annotation/json_annotation.dart';

/// Notification type enum matching backend values.
enum NotificationType {
  @JsonValue('Message')
  message,

  @JsonValue('RentalRequest')
  rentalRequest,

  @JsonValue('Upvote')
  upvote,

  @JsonValue('Comment')
  comment,

  @JsonValue('Review')
  review,

  @JsonValue('System')
  system,
}
