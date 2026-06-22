import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/listing_status.dart';
import '../../data/listings_repository.dart';
import '../../models/listing_summary_dto.dart';
import 'listings_provider.dart' show listingsRepositoryProvider;

/// State for the My Listings screen.
class MyListingsState {
  final List<ListingSummaryDto> listings;
  final ListingStatus? statusFilter;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const MyListingsState({
    this.listings = const [],
    this.statusFilter,
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  MyListingsState copyWith({
    List<ListingSummaryDto>? listings,
    ListingStatus? statusFilter,
    bool clearStatusFilter = false,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MyListingsState(
      listings: listings ?? this.listings,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for the My Listings screen.
class MyListingsNotifier extends StateNotifier<MyListingsState> {
  final ListingsRepository _repository;

  MyListingsNotifier(this._repository) : super(const MyListingsState());

  /// Load the first page of listings.
  Future<void> loadListings({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        listings: [],
        currentPage: 1,
        hasMore: true,
      );
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    // ignore: unused_label
    try {
      final response = await _repository.getMyListings(
        status: state.statusFilter,
        page: 1,
      );

      state = state.copyWith(
        listings: response.items,
        currentPage: 1,
        isLoading: false,
        hasMore: response.hasMore,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách bài đăng. ${e.toString()}',
      );
    }
  }

  /// Load the next page (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    // ignore: unused_label
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getMyListings(
        status: state.statusFilter,
        page: nextPage,
      );

      state = state.copyWith(
        listings: [...state.listings, ...response.items],
        currentPage: nextPage,
        isLoadingMore: false,
        hasMore: response.hasMore,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Không thể tải thêm. ${e.toString()}',
      );
    }
  }

  /// Set the status filter and reload.
  void setStatusFilter(ListingStatus? status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    loadListings(refresh: true);
  }

  /// Close a listing by ID.
  Future<bool> closeListing(String listingId) async {
    // ignore: unused_label
    try {
      await _repository.closeListing(listingId);
      // Update local state
      state = state.copyWith(
        listings: state.listings.map((l) {
          if (l.id == listingId) {
            return ListingSummaryDto(
              id: l.id,
              title: l.title,
              coverImageUrl: l.coverImageUrl,
              listingType: l.listingType,
              status: ListingStatus.closed,
              pricePerDay: l.pricePerDay,
              depositAmount: l.depositAmount,
              categoryName: l.categoryName,
              schoolName: l.schoolName,
              areaName: l.areaName,
              owner: l.owner,
              upvoteCount: l.upvoteCount,
              commentCount: l.commentCount,
              createdAt: l.createdAt,
            );
          }
          return l;
        }).toList(),
      );
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể đóng bài đăng. ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete a listing by ID.
  Future<bool> deleteListing(String listingId) async {
    // ignore: unused_label
    try {
      await _repository.deleteListing(listingId);
      state = state.copyWith(
        listings: state.listings.where((l) => l.id != listingId).toList(),
      );
      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        errorMessage: 'Không thể xóa bài đăng. ${e.toString()}',
      );
      return false;
    }
  }
}

/// Provider for the My Listings screen.
final myListingsProvider =
    StateNotifierProvider<MyListingsNotifier, MyListingsState>((ref) {
  return MyListingsNotifier(ref.read(listingsRepositoryProvider));
});
