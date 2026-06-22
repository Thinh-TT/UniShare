import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;
import '../../data/rentals_api.dart';
import '../../data/rentals_repository.dart';

/// Provider for RentalsApi singleton.
final rentalsApiProvider = Provider<RentalsApi>((ref) {
  return RentalsApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for RentalsRepository singleton.
final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return RentalsRepository(
    rentalsApi: ref.read(rentalsApiProvider),
  );
});
