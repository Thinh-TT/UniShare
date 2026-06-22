import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/refresh_token_request.dart';
import '../models/login_response.dart';
import '../../users/models/user_profile_dto.dart';

/// Low-level API calls for authentication endpoints.
class AuthApi {
  final ApiClient _apiClient;

  AuthApi({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.login,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.register,
      data: request.toJson(),
    );
    return response;
  }

  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await _apiClient.postRaw(
      path: ApiEndpoints.refreshToken,
      data: request.toJson(),
    );
    return LoginResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.postRaw(
        path: ApiEndpoints.logout,
      );
    } catch (_) {
      // Logout is best-effort
    }
  }

  Future<UserProfileDto> getMyProfile() async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.myProfile,
    );
    return UserProfileDto.fromJson(
        response['data'] as Map<String, dynamic>);
  }
}
