import 'package:json_annotation/json_annotation.dart';

/// Listing type enum matching backend values.
enum ListingType {
  /// Cho thuê
  @JsonValue('Rent')
  rent,

  /// Cho mượn miễn phí
  @JsonValue('Borrow')
  borrow,
}
