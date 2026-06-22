import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rental_request_summary_dto.dart';
import '../../data/rentals_repository.dart';
import 'rentals_provider.dart' show rentalsRepositoryProvider;

/// State for the My Requests screen.
class MyRequestsState {
  final List<RentalRequestSummaryDto> requests;
  final String? roleFilter;
  final String? statusFilter;
  final int currentPage;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  const MyRequestsState({
    this.requests = const [],
    this.roleFilter,
    this.statusFilter,
    this.currentPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  MyRequestsState copyWith({
    List<RentalRequestSummaryDto>? requests,
    String? roleFilter,
    bool clearRoleFilter = false,
    String? statusFilter,
    bool clearStatusFilter = false,
    int? currentPage,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return MyRequestsState(
      requests: requests ?? this.requests,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
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

/// Notifier for the My Requests screen.
class MyRequestsNotifier extends StateNotifier<MyRequestsState> {
  final RentalsRepository _repository;

  MyRequestsNotifier(this._repository) : super(const MyRequestsState());

  /// Load the first page of requests.
  Future<void> loadRequests({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        requests: [],
        currentPage: 1,
        hasMore: true,
      );
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final response = await _repository.getMyRentalRequests(
        role: state.roleFilter,
        status: state.statusFilter,
        page: 1,
      );

      state = state.copyWith(
        requests: response.items,
        currentPage: 1,
        isLoading: false,
        hasMore: response.hasMore,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách yêu cầu. ${e.toString()}',
      );
    }
  }

  /// Load the next page (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getMyRentalRequests(
        role: state.roleFilter,
        status: state.statusFilter,
        page: nextPage,
      );

      state = state.copyWith(
        requests: [...state.requests, ...response.items],
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

  /// Set the role filter and reload.
  void setRoleFilter(String? role) {
    if (state.roleFilter == role) return;
    state = state.copyWith(
      roleFilter: role,
      clearRoleFilter: role == null,
    );
    loadRequests(refresh: true);
  }

  /// Set the status filter and reload.
  void setStatusFilter(String? status) {
    if (state.statusFilter == status) return;
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    loadRequests(refresh: true);
  }
}

/// Provider for the My Requests screen.
final myRequestsProvider =
    StateNotifierProvider<MyRequestsNotifier, MyRequestsState>((ref) {
  return MyRequestsNotifier(ref.read(rentalsRepositoryProvider));
});
