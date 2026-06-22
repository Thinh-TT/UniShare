import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../models/rental_request_detail_dto.dart';
import '../../data/rentals_repository.dart';
import 'rentals_provider.dart' show rentalsRepositoryProvider;

/// Sealed state for the rental request detail screen.
sealed class RentalRequestDetailState {
  const RentalRequestDetailState();
}

class RentalRequestDetailLoading extends RentalRequestDetailState {
  const RentalRequestDetailLoading();
}

class RentalRequestDetailLoaded extends RentalRequestDetailState {
  final RentalRequestDetailDto request;
  final String currentUserId;
  final bool isActionInProgress;
  final String? actionError;

  const RentalRequestDetailLoaded({
    required this.request,
    required this.currentUserId,
    this.isActionInProgress = false,
    this.actionError,
  });

  RentalRequestDetailLoaded copyWith({
    RentalRequestDetailDto? request,
    String? currentUserId,
    bool? isActionInProgress,
    String? actionError,
    bool clearActionError = false,
  }) {
    return RentalRequestDetailLoaded(
      request: request ?? this.request,
      currentUserId: currentUserId ?? this.currentUserId,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionError:
          clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  /// Whether the current user is the requester.
  bool get isRequester => currentUserId == request.requesterId;

  /// Whether the current user is the owner.
  bool get isOwner => currentUserId == request.ownerId;

  /// Whether the current user is a participant in this request.
  bool get isParticipant => isRequester || isOwner;
}

class RentalRequestDetailError extends RentalRequestDetailState {
  final String message;
  const RentalRequestDetailError(this.message);
}

/// Notifier for the rental request detail screen.
class RentalRequestDetailNotifier
    extends StateNotifier<RentalRequestDetailState> {
  final RentalsRepository _repository;
  final String _requestId;

  RentalRequestDetailNotifier({
    required RentalsRepository repository,
    required String requestId,
    String? currentUserId,
  })  : _repository = repository,
        _requestId = requestId,
        super(const RentalRequestDetailLoading());

  /// Load the detail from the API.
  Future<void> loadDetail({String? currentUserId}) async {
    state = const RentalRequestDetailLoading();

    try {
      final request = await _repository.getRentalRequestDetail(_requestId);
      state = RentalRequestDetailLoaded(
        request: request,
        currentUserId: currentUserId ?? '',
      );
    } on Exception catch (e) {
      state = RentalRequestDetailError(
        'Không thể tải chi tiết yêu cầu. ${e.toString()}',
      );
    }
  }

  /// Shared helper for performing actions.
  Future<void> _performAction(
    Future<RentalRequestDetailDto> Function() action,
  ) async {
    if (state is! RentalRequestDetailLoaded) return;
    final current = state as RentalRequestDetailLoaded;
    state = current.copyWith(isActionInProgress: true, clearActionError: true);

    try {
      final updated = await action();
      state = RentalRequestDetailLoaded(
        request: updated,
        currentUserId: current.currentUserId,
      );
    } on Exception catch (e) {
      if (state is RentalRequestDetailLoaded) {
        state = (state as RentalRequestDetailLoaded).copyWith(
          isActionInProgress: false,
          actionError: _mapError(e.toString()),
        );
      }
    }
  }

  Future<void> acceptRequest() => _performAction(
        () => _repository.acceptRequest(_requestId),
      );

  Future<void> rejectRequest() => _performAction(
        () => _repository.rejectRequest(_requestId),
      );

  Future<void> cancelRequest() => _performAction(
        () => _repository.cancelRequest(_requestId),
      );

  Future<void> startTransaction() => _performAction(
        () => _repository.startRequest(_requestId),
      );

  Future<void> completeTransaction() => _performAction(
        () => _repository.completeRequest(_requestId),
      );

  String _mapError(String error) {
    if (error.contains('403')) {
      return 'Bạn không có quyền thực hiện hành động này';
    }
    if (error.contains('409')) {
      return 'Không thể thực hiện ở trạng thái hiện tại';
    }
    if (error.contains('404')) {
      return 'Yêu cầu không tồn tại';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
  }
}

/// Provider for the rental request detail screen, keyed by requestId.
final rentalRequestDetailProvider = StateNotifierProvider.family<
    RentalRequestDetailNotifier,
    RentalRequestDetailState,
    String>((ref, requestId) {
  final authState = ref.read(authProvider);
  final currentUserId =
      authState is AuthAuthenticated ? authState.user.id : null;

  final notifier = RentalRequestDetailNotifier(
    repository: ref.read(rentalsRepositoryProvider),
    requestId: requestId,
    currentUserId: currentUserId,
  );
  notifier.loadDetail(currentUserId: currentUserId);
  return notifier;
});
