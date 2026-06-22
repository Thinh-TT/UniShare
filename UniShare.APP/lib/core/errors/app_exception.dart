/// Unified exception hierarchy for API and network errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({required String message})
      : super(message: message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({String message = 'Unauthorized'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException({String message = 'Forbidden'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException({String message = 'Not found'})
      : super(message: message, statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException({String message = 'Conflict'})
      : super(message: message, statusCode: 409);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 422);
}

class ServerException extends AppException {
  const ServerException({String message = 'Internal server error'})
      : super(message: message, statusCode: 500);
}
