library;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'No internet connection']);
}

class ServerException extends ApiException {
  ServerException([super.message = 'Server error occurred', int? statusCode])
    : super(statusCode: statusCode);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized access'])
    : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Resource not found'])
    : super(statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, {this.errors}) : super(statusCode: 422);
}

class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Request timed out']);
}
