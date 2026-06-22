import 'package:json_annotation/json_annotation.dart';
import '../../../core/enums/rental_request_status.dart';
import '../../../core/enums/deposit_status.dart';
import '../../users/models/user_summary_dto.dart';

part 'rental_request_dto.g.dart';

@JsonSerializable()
class RentalRequestDto {
  final String id;
  final String listingId;
  final String? listingTitle;
  final UserSummaryDto? requester;
  final UserSummaryDto? owner;
  final RentalRequestStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double depositAmount;
  final DepositStatus? depositStatus;
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RentalRequestDto({
    required this.id,
    required this.listingId,
    this.listingTitle,
    this.requester,
    this.owner,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.depositAmount,
    this.depositStatus,
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  factory RentalRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RentalRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RentalRequestDtoToJson(this);
}
