import 'user_api.dart';
import '../models/user_profile_dto.dart';
import '../models/update_profile_request.dart';

/// Repository orchestrating user profile operations.
class UserRepository {
  final UserApi _userApi;

  UserRepository({required UserApi userApi}) : _userApi = userApi;

  /// Get the current user's profile.
  Future<UserProfileDto> getProfile() => _userApi.getMyProfile();

  /// Update the current user's profile.
  Future<UserProfileDto> updateProfile(UpdateProfileRequest request) =>
      _userApi.updateProfile(request);
}
