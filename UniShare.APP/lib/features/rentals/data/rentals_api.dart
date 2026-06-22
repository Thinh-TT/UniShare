import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/rental_request_detail_dto.dart';
import '../models/rental_request_summary_dto.dart';
import '../models/create_rental_request_request.dart';

/// Low-level API calls for rental requests.
class RentalsApi {
  final ApiClient _apiClient;

  RentalsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a rental request for a listing.
  Future<RentalRequestDetailDto> createRentalRequest(
    String listingId,
    CreateRentalRequestRequest request,
  ) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.rentalRequests(listingId),
      data: request.toJson(),
    );
    return RentalRequestDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Get current user's rental requests (as requester or owner).
  Future<PagedResponse<RentalRequestSummaryDto>> getMyRentalRequests({
    String? role,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (role != null) queryParams['role'] = role;
    if (status != null) queryParams['status'] = status;

    return _apiClient.getPaged<RentalRequestSummaryDto>(
      path: ApiEndpoints.myRentalRequests,
      queryParams: queryParams,
      fromJsonT: (json) => RentalRequestSummaryDto.fromJson(json),
    );
  }

  /// Get a single rental request by ID.
  Future<RentalRequestDetailDto> getRentalRequestDetail(
      String requestId) async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.rentalRequestById(requestId),
    );
    return RentalRequestDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Accept a rental request (owner only).
  Future<RentalRequestDetailDto> acceptRequest(String requestId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.acceptRequest(requestId),
      fromJsonT: (json) => json,
    );
    return RentalRequestDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Reject a rental request (owner only).
  Future<RentalRequestDetailDto> rejectRequest(String requestId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.rejectRequest(requestId),
      fromJsonT: (json) => json,
    );
    return RentalRequestDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Cancel a rental request (requester only).
  Future<RentalRequestDetailDto> cancelRequest(String requestId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.cancelRequest(requestId),
      fromJsonT: (json) => json,
    );
    return RentalRequestDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Start transaction (owner only, changes status to InProgress).
  Future<RentalRequestDetailDto> startRequest(String requestId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.startRequest(requestId),
      fromJsonT: (json) => json,
    );
    return RentalRequestDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Complete transaction (either party, changes status to Completed).
  Future<RentalRequestDetailDto> completeRequest(String requestId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.completeRequest(requestId),
      fromJsonT: (json) => json,
    );
    return RentalRequestDetailDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
