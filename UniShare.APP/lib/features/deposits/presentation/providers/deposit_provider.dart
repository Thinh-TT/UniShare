import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/deposits_api.dart';
import '../../data/deposits_repository.dart';
import '../../models/deposit_dto.dart';

/// Provider for DepositsApi singleton.
final depositsApiProvider = Provider<DepositsApi>((ref) {
  return DepositsApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for DepositsRepository singleton.
final depositsRepositoryProvider = Provider<DepositsRepository>((ref) {
  return DepositsRepository(
    depositsApi: ref.read(depositsApiProvider),
  );
});

/// Sealed state for the deposit screen.
sealed class DepositState {
  const DepositState();
}

class DepositLoading extends DepositState {
  const DepositLoading();
}

class DepositLoaded extends DepositState {
  final DepositDto deposit;
  final bool isActionInProgress;
  final String? actionError;

  const DepositLoaded({
    required this.deposit,
    this.isActionInProgress = false,
    this.actionError,
  });

  DepositLoaded copyWith({
    DepositDto? deposit,
    bool? isActionInProgress,
    String? actionError,
    bool clearActionError = false,
  }) {
    return DepositLoaded(
      deposit: deposit ?? this.deposit,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionError:
          clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}

class DepositNotFound extends DepositState {
  const DepositNotFound();
}

class DepositError extends DepositState {
  final String message;
  const DepositError(this.message);
}

/// Notifier for the deposit screen.
class DepositNotifier extends StateNotifier<DepositState> {
  final DepositsRepository _repository;
  final String _requestId;

  DepositNotifier({
    required DepositsRepository repository,
    required String requestId,
  })  : _repository = repository,
        _requestId = requestId,
        super(const DepositLoading());

  Future<void> loadDeposit() async {
    state = const DepositLoading();

    try {
      final deposit = await _repository.getDepositByRequest(_requestId);
      state = DepositLoaded(deposit: deposit);
    } on Exception catch (e) {
      final message = e.toString();
      if (message.contains('404')) {
        state = const DepositNotFound();
      } else {
        state = DepositError(
          'Không thể tải thông tin đặt cọc. $message',
        );
      }
    }
  }

  Future<void> _performAction(
    Future<DepositDto> Function() action,
  ) async {
    if (state is! DepositLoaded) return;
    final current = state as DepositLoaded;
    state = current.copyWith(isActionInProgress: true, clearActionError: true);

    try {
      final updated = await action();
      state = DepositLoaded(deposit: updated);
    } on Exception catch (e) {
      if (state is DepositLoaded) {
        state = (state as DepositLoaded).copyWith(
          isActionInProgress: false,
          actionError: 'Thao tác thất bại: $e',
        );
      }
    }
  }

  Future<void> markPaid(String depositId) =>
      _performAction(() => _repository.markDepositPaid(depositId));

  Future<void> refund(String depositId) =>
      _performAction(() => _repository.refundDeposit(depositId));
}

/// Provider for the deposit screen, keyed by requestId.
final depositProvider = StateNotifierProvider.family<DepositNotifier,
    DepositState, String>((ref, requestId) {
  final notifier = DepositNotifier(
    repository: ref.read(depositsRepositoryProvider),
    requestId: requestId,
  );
  notifier.loadDeposit();
  return notifier;
});
