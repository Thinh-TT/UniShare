import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/enums/listing_type.dart';
import '../../../core/enums/listing_status.dart';
import '../models/listing_summary_dto.dart';
import '../models/listing_detail_dto.dart';
import '../models/create_listing_request.dart';
import '../models/update_listing_request.dart';

/// Low-level API calls for listings.
class ListingsApi {
  final ApiClient _apiClient;

  ListingsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Search/filter listings with pagination.
  Future<PagedResponse<ListingSummaryDto>> getListings({
    String? keyword,
    String? categoryId,
    String? tag,
    String? schoolId,
    String? areaId,
    ListingType? listingType,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int pageSize = 20,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (tag != null && tag.isNotEmpty) queryParams['tag'] = tag;
    if (schoolId != null) queryParams['schoolId'] = schoolId;
    if (areaId != null) queryParams['areaId'] = areaId;
    if (listingType != null) queryParams['listingType'] = listingType.name;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortDirection != null) queryParams['sortDirection'] = sortDirection;

    return _apiClient.getPaged<ListingSummaryDto>(
      path: ApiEndpoints.listings,
      queryParams: queryParams,
      fromJsonT: (json) => ListingSummaryDto.fromJson(json),
    );
  }

  /// Get a single listing by ID.
  Future<ListingDetailDto> getListingDetail(String listingId) async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.listingById(listingId),
    );
    return ListingDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Create a new listing.
  Future<ListingDetailDto> createListing(CreateListingRequest request) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.listings,
      data: request.toJson(),
    );
    return ListingDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Update an existing listing.
  Future<ListingDetailDto> updateListing(
    String listingId,
    UpdateListingRequest request,
  ) async {
    final response = await _apiClient.putRaw(
      path: ApiEndpoints.listingById(listingId),
      data: request.toJson(),
    );
    return ListingDetailDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Close a listing (soft).
  Future<void> closeListing(String listingId) async {
    await _apiClient.patch<void>(
      path: ApiEndpoints.closeListing(listingId),
      fromJsonT: (_) => null,
    );
  }

  /// Delete a listing (soft delete).
  Future<void> deleteListing(String listingId) async {
    await _apiClient.delete(path: ApiEndpoints.listingById(listingId));
  }

  /// Get the current user's own listings.
  Future<PagedResponse<ListingSummaryDto>> getMyListings({
    ListingStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null) queryParams['status'] = status.name;

    return _apiClient.getPaged<ListingSummaryDto>(
      path: ApiEndpoints.myListings,
      queryParams: queryParams,
      fromJsonT: (json) => ListingSummaryDto.fromJson(json),
    );
  }

  /// Toggle upvote on a listing. If already upvoted, call DELETE; otherwise PUT.
  Future<void> toggleUpvote(String listingId, bool isUpvoted) async {
    if (isUpvoted) {
      await _apiClient.delete(path: ApiEndpoints.upvote(listingId));
    } else {
      await _apiClient.put<void>(
        path: ApiEndpoints.upvote(listingId),
        fromJsonT: (_) => null,
      );
    }
  }
}
