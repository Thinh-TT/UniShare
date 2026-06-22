import 'package:json_annotation/json_annotation.dart';

/// Listing status enum matching backend values.
enum ListingStatus {
  @JsonValue('Available')
  available,

  @JsonValue('Reserved')
  reserved,

  @JsonValue('InUse')
  inUse,

  @JsonValue('Closed')
  closed,
}
