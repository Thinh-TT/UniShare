import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_api.dart';
import '../../data/user_repository.dart';
import '../../models/user_profile_dto.dart';
import '../../../auth/presentation/providers/auth_provider.dart'
    show apiClientProvider;

/// Provider for UserApi singleton.
final userApiProvider = Provider<UserApi>((ref) {
  return UserApi(apiClient: ref.read(apiClientProvider));
});

/// Provider for UserRepository singleton.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(userApi: ref.read(userApiProvider));
});

/// Provider that fetches the current user's profile.
///
/// Invalidate with [ref.invalidate(userProfileProvider)] to force a refresh.
final userProfileProvider = FutureProvider<UserProfileDto>((ref) async {
  return ref.read(userRepositoryProvider).getProfile();
});
