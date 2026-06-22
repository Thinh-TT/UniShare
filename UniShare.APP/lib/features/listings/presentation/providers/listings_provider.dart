import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../data/listings_api.dart';
import '../../data/listings_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../../../core/enums/listing_type.dart';
import '../../models/listing_summary_dto.dart';
import '../../models/listing_detail_dto.dart';

/// Provider for ListingsApi singleton.
final listingsApiProvider = Provider<ListingsApi>((ref) {
  return ListingsApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for ListingsRepository singleton.
final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(
    listingsApi: ref.read(listingsApiProvider),
  );
});

/// Parameters for filtering listings.
///
/// All fields are optional; null means "no filter".
class ListingFilterParams {
  final String? keyword;
  final String? categoryId;
  final String? tag;
  final String? schoolId;
  final String? areaId;
  final String? listingType;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortDirection;

  const ListingFilterParams({
    this.keyword,
    this.categoryId,
    this.tag,
    this.schoolId,
    this.areaId,
    this.listingType,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortDirection,
  });

  /// Default filter: newest listings first, no other filters.
  static const defaultFilter = ListingFilterParams(
    sortBy: 'createdAt',
    sortDirection: 'desc',
  );

  /// Create a copy with the given fields replaced.
  ListingFilterParams copyWith({
    String? keyword,
    String? categoryId,
    String? tag,
    String? schoolId,
    String? areaId,
    String? listingType,
    double? minPrice,
    double? maxPrice,
    int? page,
    int? pageSize,
    String? sortBy,
    String? sortDirection,
    bool clearKeyword = false,
    bool clearCategoryId = false,
    bool clearTag = false,
    bool clearSchoolId = false,
    bool clearAreaId = false,
    bool clearListingType = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ListingFilterParams(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      tag: clearTag ? null : (tag ?? this.tag),
      schoolId: clearSchoolId ? null : (schoolId ?? this.schoolId),
      areaId: clearAreaId ? null : (areaId ?? this.areaId),
      listingType:
          clearListingType ? null : (listingType ?? this.listingType),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  /// Whether any non-default filter is active.
  bool get hasActiveFilters =>
      keyword != null ||
      categoryId != null ||
      tag != null ||
      schoolId != null ||
      areaId != null ||
      listingType != null ||
      minPrice != null ||
      maxPrice != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingFilterParams &&
          keyword == other.keyword &&
          categoryId == other.categoryId &&
          tag == other.tag &&
          schoolId == other.schoolId &&
          areaId == other.areaId &&
          listingType == other.listingType &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          page == other.page &&
          pageSize == other.pageSize &&
          sortBy == other.sortBy &&
          sortDirection == other.sortDirection;

  @override
  int get hashCode => Object.hash(
        keyword,
        categoryId,
        tag,
        schoolId,
        areaId,
        listingType,
        minPrice,
        maxPrice,
        page,
        pageSize,
        sortBy,
        sortDirection,
      );
}

/// Provider for the paginated listing list (FutureProvider.family by filter params).
final listingsProvider = FutureProvider.family<
    PagedResponse<ListingSummaryDto>,
    ListingFilterParams>((ref, filters) async {
  return ref.read(listingsRepositoryProvider).getListings(
        keyword: filters.keyword,
        categoryId: filters.categoryId,
        tag: filters.tag,
        schoolId: filters.schoolId,
        areaId: filters.areaId,
        listingType: filters.listingType != null
            ? filters.listingType == 'rent'
                ? ListingType.rent
                : ListingType.borrow
            : null,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        page: filters.page,
        pageSize: filters.pageSize,
        sortBy: filters.sortBy,
        sortDirection: filters.sortDirection,
      );
});

/// Provider for a single listing detail (FutureProvider.family by listingId).
final listingDetailProvider =
    FutureProvider.family<ListingDetailDto, String>((ref, listingId) async {
  return ref.read(listingsRepositoryProvider).getListingDetail(listingId);
});
