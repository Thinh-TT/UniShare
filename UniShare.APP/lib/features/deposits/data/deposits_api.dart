import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../deposits/models/deposit_dto.dart';

/// Low-level API calls for deposits.
class DepositsApi {
  final ApiClient _apiClient;

  DepositsApi({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get deposit by rental request ID.
  Future<DepositDto> getDepositByRequest(String requestId) async {
    final response = await _apiClient.getRaw(
      path: ApiEndpoints.depositByRequest(requestId),
    );
    return DepositDto.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Mark a deposit as paid (owner only).
  Future<DepositDto> markDepositPaid(String depositId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.markDepositPaid(depositId),
      fromJsonT: (json) => json,
    );
    return DepositDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Refund a deposit (owner only).
  Future<DepositDto> refundDeposit(String depositId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.refundDeposit(depositId),
      fromJsonT: (json) => json,
    );
    return DepositDto.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
