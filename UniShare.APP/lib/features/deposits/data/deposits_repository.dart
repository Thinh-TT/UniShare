import '../../deposits/models/deposit_dto.dart';
import 'deposits_api.dart';

/// Business logic orchestration for deposits.
class DepositsRepository {
  final DepositsApi _depositsApi;

  DepositsRepository({required DepositsApi depositsApi})
      : _depositsApi = depositsApi;

  Future<DepositDto> getDepositByRequest(String requestId) {
    return _depositsApi.getDepositByRequest(requestId);
  }

  Future<DepositDto> markDepositPaid(String depositId) {
    return _depositsApi.markDepositPaid(depositId);
  }

  Future<DepositDto> refundDeposit(String depositId) {
    return _depositsApi.refundDeposit(depositId);
  }
}
