import 'package:json_annotation/json_annotation.dart';
import '../../deposits/models/deposit_dto.dart';

part 'rental_request_detail_dto.g.dart';

/// Full rental request detail matching backend RentalRequestDetailDto.
///
/// Uses flat fields (requesterId, requesterName, etc.) matching the backend
/// response shape. The existing RentalRequestDto uses nested UserSummaryDto
/// objects and is kept for backward compatibility where needed.
@JsonSerializable()
class RentalRequestDetailDto {
  final String id;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? message;
  final double totalPrice;
  final double? depositAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String listingId;
  final String listingTitle;
  final String? listingImageUrl;
  final double listingPricePerDay;
  final String listingType;
  final String requesterId;
  final String requesterName;
  final String? requesterAvatarUrl;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final DepositDto? deposit;

  const RentalRequestDetailDto({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.message,
    required this.totalPrice,
    this.depositAmount,
    required this.createdAt,
    this.updatedAt,
    required this.listingId,
    required this.listingTitle,
    this.listingImageUrl,
    required this.listingPricePerDay,
    required this.listingType,
    required this.requesterId,
    required this.requesterName,
    this.requesterAvatarUrl,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatarUrl,
    this.deposit,
  });

  factory RentalRequestDetailDto.fromJson(Map<String, dynamic> json) =>
      _$RentalRequestDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RentalRequestDetailDtoToJson(this);
}
