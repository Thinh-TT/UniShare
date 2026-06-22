import '../../../core/enums/listing_type.dart';
import '../../../core/enums/listing_status.dart';
import '../../../core/network/api_response.dart';
import '../models/listing_summary_dto.dart';
import '../models/listing_detail_dto.dart';
import '../models/create_listing_request.dart';
import '../models/update_listing_request.dart';
import 'listings_api.dart';

/// Business logic orchestration for listings.
class ListingsRepository {
  final ListingsApi _listingsApi;

  ListingsRepository({required ListingsApi listingsApi})
      : _listingsApi = listingsApi;

  /// Search/filter listings.
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
  }) {
    return _listingsApi.getListings(
      keyword: keyword,
      categoryId: categoryId,
      tag: tag,
      schoolId: schoolId,
      areaId: areaId,
      listingType: listingType,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  /// Get listing detail by ID.
  Future<ListingDetailDto> getListingDetail(String listingId) {
    return _listingsApi.getListingDetail(listingId);
  }

  /// Create a new listing.
  Future<ListingDetailDto> createListing(CreateListingRequest request) {
    return _listingsApi.createListing(request);
  }

  /// Update an existing listing.
  Future<ListingDetailDto> updateListing(
    String listingId,
    UpdateListingRequest request,
  ) {
    return _listingsApi.updateListing(listingId, request);
  }

  /// Close a listing.
  Future<void> closeListing(String listingId) {
    return _listingsApi.closeListing(listingId);
  }

  /// Delete a listing.
  Future<void> deleteListing(String listingId) {
    return _listingsApi.deleteListing(listingId);
  }

  /// Get current user's own listings.
  Future<PagedResponse<ListingSummaryDto>> getMyListings({
    ListingStatus? status,
    int page = 1,
    int pageSize = 20,
  }) {
    return _listingsApi.getMyListings(
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Toggle upvote on a listing.
  Future<void> toggleUpvote(String listingId, bool isUpvoted) {
    return _listingsApi.toggleUpvote(listingId, isUpvoted);
  }
}
