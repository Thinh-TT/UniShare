import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rental_request_detail_dto.dart';
import '../../models/create_rental_request_request.dart';
import '../../data/rentals_repository.dart';
import 'rentals_provider.dart' show rentalsRepositoryProvider;

/// Sealed state for the rental request form.
sealed class RentalRequestFormState {
  const RentalRequestFormState();
}

class RentalRequestFormInitial extends RentalRequestFormState {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? message;
  final bool isSubmitting;
  final String? error;
  final String listingTitle;
  final double listingPricePerDay;
  final double listingDepositAmount;
  final String listingType;

  const RentalRequestFormInitial({
    this.startDate,
    this.endDate,
    this.message,
    this.isSubmitting = false,
    this.error,
    required this.listingTitle,
    required this.listingPricePerDay,
    required this.listingDepositAmount,
    required this.listingType,
  });

  RentalRequestFormInitial copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? message,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return RentalRequestFormInitial(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      message: clearMessage ? null : (message ?? this.message),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      listingTitle: listingTitle,
      listingPricePerDay: listingPricePerDay,
      listingDepositAmount: listingDepositAmount,
      listingType: listingType,
    );
  }

  /// Calculate total price in days × price per day.
  /// Returns 0 if dates are not set.
  int get calculatedTotalPrice {
    if (startDate == null || endDate == null) return 0;
    final days = endDate!.difference(startDate!).inDays + 1;
    if (days < 1) return 0;
    return (days * listingPricePerDay).round();
  }

  /// Number of days between start and end (inclusive).
  int get numberOfDays {
    if (startDate == null || endDate == null) return 0;
    final days = endDate!.difference(startDate!).inDays + 1;
    return days < 1 ? 0 : days;
  }

  /// Whether the form is valid to submit.
  bool get isValid =>
      startDate != null &&
      endDate != null &&
      !endDate!.isBefore(startDate!);
}

class RentalRequestFormSubmitting extends RentalRequestFormState {
  const RentalRequestFormSubmitting();
}

class RentalRequestFormSuccess extends RentalRequestFormState {
  final RentalRequestDetailDto request;
  const RentalRequestFormSuccess(this.request);
}

class RentalRequestFormError extends RentalRequestFormState {
  final String message;
  const RentalRequestFormError(this.message);
}

/// Notifier for the rental request form.
class RentalRequestFormNotifier
    extends StateNotifier<RentalRequestFormState> {
  final RentalsRepository _repository;
  final String _listingId;

  RentalRequestFormNotifier({
    required RentalsRepository repository,
    required String listingId,
    required String listingTitle,
    required double listingPricePerDay,
    required double listingDepositAmount,
    required String listingType,
  })  : _repository = repository,
        _listingId = listingId,
        super(RentalRequestFormInitial(
          listingTitle: listingTitle,
          listingPricePerDay: listingPricePerDay,
          listingDepositAmount: listingDepositAmount,
          listingType: listingType,
        ));

  void setStartDate(DateTime date) {
    if (state is RentalRequestFormInitial) {
      final s = state as RentalRequestFormInitial;
      state = s.copyWith(startDate: date, clearError: true);
    }
  }

  void setEndDate(DateTime date) {
    if (state is RentalRequestFormInitial) {
      final s = state as RentalRequestFormInitial;
      state = s.copyWith(endDate: date, clearError: true);
    }
  }

  void setMessage(String message) {
    if (state is RentalRequestFormInitial) {
      final s = state as RentalRequestFormInitial;
      state = s.copyWith(
        message: message.isEmpty ? null : message,
        clearMessage: message.isEmpty,
      );
    }
  }

  Future<void> submit() async {
    if (state is! RentalRequestFormInitial) return;
    final s = state as RentalRequestFormInitial;

    // Validate
    if (s.startDate == null || s.endDate == null) {
      state = s.copyWith(error: 'Vui lòng chọn ngày bắt đầu và kết thúc');
      return;
    }
    if (s.endDate!.isBefore(s.startDate!)) {
      state = s.copyWith(error: 'Ngày kết thúc phải sau ngày bắt đầu');
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (s.startDate!.isBefore(today)) {
      state = s.copyWith(error: 'Ngày bắt đầu không được trong quá khứ');
      return;
    }

    state = const RentalRequestFormSubmitting();

    try {
      final result = await _repository.createRentalRequest(
        _listingId,
        CreateRentalRequestRequest(
          startDate: s.startDate!,
          endDate: s.endDate!,
          message: s.message,
        ),
      );
      state = RentalRequestFormSuccess(result);
    } on Exception catch (e) {
      final message = e.toString();
      final displayMessage = _mapError(message);
      state = RentalRequestFormError(displayMessage);
    }
  }

  String _mapError(String error) {
    if (error.contains('409')) {
      return 'Bạn đã có yêu cầu đang hoạt động cho bài đăng này';
    }
    if (error.contains('403')) {
      return 'Bạn không thể gửi yêu cầu cho bài đăng của chính mình';
    }
    if (error.contains('400')) {
      return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    }
    return 'Không thể gửi yêu cầu. Vui lòng thử lại sau.';
  }
}

/// Provider for the rental request form, keyed by listingId.
final rentalRequestFormProvider = StateNotifierProvider.family<
    RentalRequestFormNotifier,
    RentalRequestFormState,
    String>((ref, listingId) {
  throw UnimplementedError(
      'Use rentalRequestFormProvider with extra params from route');
});

/// Creates a RentalRequestFormNotifier with listing metadata.
RentalRequestFormNotifier createRentalRequestFormNotifier({
  required Ref ref,
  required String listingId,
  required String listingTitle,
  required double listingPricePerDay,
  required double listingDepositAmount,
  required String listingType,
}) {
  return RentalRequestFormNotifier(
    repository: ref.read(rentalsRepositoryProvider),
    listingId: listingId,
    listingTitle: listingTitle,
    listingPricePerDay: listingPricePerDay,
    listingDepositAmount: listingDepositAmount,
    listingType: listingType,
  );
}
