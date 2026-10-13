// The reason a request failed, named so that the wording stays out of the
// exception: the app translates a code through `t.errors`, which keeps the
// message in the language the user picked.
enum AppErrorCode {
  network,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  badRequest,
  server,
  unknown,
  signingIn,
  studentNameRequired,
  groupNameRequired,
  invalidPrice,
  studentNameNotUnique,
  groupNameNotUnique;

  // The code the backend adds when one status covers several reasons at once,
  // such as a name that is already taken. A code the app does not know is
  // ignored, so a newer backend never breaks an older app.
  static AppErrorCode? fromApi(Object? code) => switch (code) {
    'STUDENT_NAME_NOT_UNIQUE' => studentNameNotUnique,
    'GROUP_NAME_NOT_UNIQUE' => groupNameNotUnique,
    _ => null,
  };

  // The failure a status names on its own. It is what most failures are worded
  // by, because the status of the problem detail already carries it.
  static AppErrorCode fromStatus(int? statusCode) => switch (statusCode) {
    400 => validation,
    401 => unauthorized,
    403 => forbidden,
    404 => notFound,
    409 => conflict,
    _ when statusCode != null && statusCode >= 500 => server,
    _ => badRequest,
  };
}

// A failure that carries the text the person in front of the screen has to read.
//
// [message] is the wording a caller shows as it is, which is what [toString]
// returns, while [code] lets the app name the failure in the language of the
// user. [cause] keeps the technical failure for the logs.
sealed class AppException implements Exception {
  const new(this.message, {this.code, this.cause});

  final String message;
  final AppErrorCode? code;
  final Object? cause;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const new({super.cause})
    : super(
        'You appear to be offline. Check your connection and try again.',
        code: AppErrorCode.network,
      );
}

final class RequestTimeoutException extends AppException {
  const new({super.cause})
    : super(
        'The server took too long to respond. Please try again.',
        code: AppErrorCode.timeout,
      );
}

final class ServerException extends AppException {
  const new({
    required this.statusCode,
    String? message,
    AppErrorCode? code,
    super.cause,
  }) : super(
         message ?? 'The server rejected the request ($statusCode). Please try again.',
         code: code ?? AppErrorCode.server,
       );

  final int? statusCode;
}

final class UnauthorizedException extends AppException {
  const new({super.cause})
    : super(
        'Your session has expired. Please sign in again.',
        code: AppErrorCode.unauthorized,
      );
}

final class ForbiddenException extends AppException {
  const new({super.cause})
    : super(
        'You do not have permission to do this.',
        code: AppErrorCode.forbidden,
      );
}

final class RequestCancelledException extends AppException {
  const new({super.cause})
    : super('The request was cancelled.', code: AppErrorCode.cancelled);
}

final class AuthenticationException extends AppException {
  const new({String? message, super.cause})
    : super(
        message ?? 'Signing in failed. Please try again.',
        code: AppErrorCode.signingIn,
      );
}

final class UnknownException extends AppException {
  const new({super.cause})
    : super(
        'Something went wrong. Please try again.',
        code: AppErrorCode.unknown,
      );
}

// Raised when user supplied data fails a domain validation rule, or when the
// backend rejects the fields of a form. The code stays empty when the message
// names those fields, because then it is more precise than a wording of the app
// can be.
final class ValidationException extends AppException {
  const new(super.message, {super.code, super.cause});
}

// Raised when the request clashes with the data that is already saved, such as a
// student or a group that carries a name the user took before.
final class ConflictException extends AppException {
  const new({String? message, AppErrorCode? code, super.cause})
    : super(
        message ?? 'This clashes with the data that is already saved.',
        code: code ?? AppErrorCode.conflict,
      );
}

// Raised when the record the request points at is gone.
final class NotFoundException extends AppException {
  const new({String? message, AppErrorCode? code, super.cause})
    : super(
        message ?? 'The record you asked for no longer exists.',
        code: code ?? AppErrorCode.notFound,
      );
}
