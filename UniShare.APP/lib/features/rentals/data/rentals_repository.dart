import '../../../core/network/api_response.dart';
import '../models/rental_request_detail_dto.dart';
import '../models/rental_request_summary_dto.dart';
import '../models/create_rental_request_request.dart';
import 'rentals_api.dart';

/// Business logic orchestration for rental requests.
class RentalsRepository {
  final RentalsApi _rentalsApi;

  RentalsRepository({required RentalsApi rentalsApi})
      : _rentalsApi = rentalsApi;

  /// Create a rental request for a listing.
  Future<RentalRequestDetailDto> createRentalRequest(
    String listingId,
    CreateRentalRequestRequest request,
  ) {
    return _rentalsApi.createRentalRequest(listingId, request);
  }

  /// Get current user's rental requests.
  Future<PagedResponse<RentalRequestSummaryDto>> getMyRentalRequests({
    String? role,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) {
    return _rentalsApi.getMyRentalRequests(
      role: role,
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get a single rental request by ID.
  Future<RentalRequestDetailDto> getRentalRequestDetail(String requestId) {
    return _rentalsApi.getRentalRequestDetail(requestId);
  }

  /// Accept a rental request (owner only).
  Future<RentalRequestDetailDto> acceptRequest(String requestId) {
    return _rentalsApi.acceptRequest(requestId);
  }

  /// Reject a rental request (owner only).
  Future<RentalRequestDetailDto> rejectRequest(String requestId) {
    return _rentalsApi.rejectRequest(requestId);
  }

  /// Cancel a rental request (requester only).
  Future<RentalRequestDetailDto> cancelRequest(String requestId) {
    return _rentalsApi.cancelRequest(requestId);
  }

  /// Start transaction (owner only).
  Future<RentalRequestDetailDto> startRequest(String requestId) {
    return _rentalsApi.startRequest(requestId);
  }

  /// Complete transaction (either party).
  Future<RentalRequestDetailDto> completeRequest(String requestId) {
    return _rentalsApi.completeRequest(requestId);
  }
}
