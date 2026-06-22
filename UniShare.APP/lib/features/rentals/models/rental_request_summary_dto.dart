import 'package:json_annotation/json_annotation.dart';

part 'rental_request_summary_dto.g.dart';

/// Rental request summary matching backend RentalRequestSummaryDto.
///
/// Flat fields used in list endpoints. The `role` field indicates
/// whether the current user is the "requester" or "owner".
@JsonSerializable()
class RentalRequestSummaryDto {
  final String id;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double? depositAmount;
  final DateTime createdAt;
  final String listingId;
  final String listingTitle;
  final String? listingImageUrl;
  final String otherParticipantId;
  final String otherParticipantName;
  final String? otherParticipantAvatarUrl;
  final String role;

  const RentalRequestSummaryDto({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    this.depositAmount,
    required this.createdAt,
    required this.listingId,
    required this.listingTitle,
    this.listingImageUrl,
    required this.otherParticipantId,
    required this.otherParticipantName,
    this.otherParticipantAvatarUrl,
    required this.role,
  });

  factory RentalRequestSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$RentalRequestSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RentalRequestSummaryDtoToJson(this);
}
