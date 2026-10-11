sealed class AppException implements Exception {
  const new(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const new({super.cause})
    : super('You appear to be offline. Check your connection and try again.');
}

final class RequestTimeoutException extends AppException {
  const new({super.cause})
    : super('The server took too long to respond. Please try again.');
}

final class ServerException extends AppException {
  const new({required this.statusCode, super.cause})
    : super('The server rejected the request ($statusCode). Please try again.');

  final int? statusCode;
}

final class UnauthorizedException extends AppException {
  const new({super.cause})
    : super('Your session has expired. Please sign in again.');
}

final class RequestCancelledException extends AppException {
  const new({super.cause}) : super('The request was cancelled.');
}

final class AuthenticationException extends AppException {
  const new({String? message, super.cause})
    : super(message ?? 'Signing in failed. Please try again.');
}

final class UnknownException extends AppException {
  const new({super.cause}) : super('Something went wrong. Please try again.');
}

/// Raised when user supplied data fails a domain validation rule.
final class ValidationException extends AppException {
  const new(super.message, {super.cause});
}
