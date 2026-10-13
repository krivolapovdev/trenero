import 'package:dio/dio.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/i18n/strings.g.dart';

extension DioExceptionMapper on DioException {
  AppException toAppException() => switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => RequestTimeoutException(cause: this),
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => NetworkException(cause: this),
    DioExceptionType.cancel => RequestCancelledException(cause: this),
    DioExceptionType.badResponse => _fromResponse(),
    DioExceptionType.unknown => UnknownException(cause: this),
  };

  AppException _fromResponse() {
    final statusCode = response?.statusCode;
    // The status names the failure; a code the backend adds names it more
    // precisely, which it only needs for a status that covers several reasons.
    final code =
        AppErrorCode.fromApi(_problemProperty('code')) ??
        AppErrorCode.fromStatus(statusCode);
    final fieldMessages = _fieldMessages();
    final detail = _problemProperty('detail') ?? _problemProperty('title');

    return switch (statusCode) {
      400 => ValidationException(
        // The fields the backend rejected are more precise than any wording the
        // app can pick, so they win over the status and stay as they are.
        fieldMessages ??
            detail ??
            'The request was rejected. Check the form and try again.',
        code: fieldMessages == null ? code : null,
        cause: this,
      ),
      401 => UnauthorizedException(cause: this),
      403 => ForbiddenException(cause: this),
      404 => NotFoundException(message: detail, cause: this),
      409 => ConflictException(message: detail, code: code, cause: this),
      _ => ServerException(
        statusCode: statusCode,
        message: detail,
        code: code,
        cause: this,
      ),
    };
  }

  // The message of the fields the backend rejected, when the request came from a
  // form. Reporting them is more precise than any wording of the app.
  String? _fieldMessages() {
    final data = response?.data;

    if (data is! Map) return null;

    final errors = data['errors'];
    if (errors is! List) return null;

    final messages = errors
        .whereType<Map>()
        .map((error) => error['message'])
        .whereType<String>()
        .map((message) => message.trim())
        .where((message) => message.isNotEmpty);

    return messages.isEmpty ? null : messages.join('\n');
  }

  // A property of the problem detail the backend answered with, if it sent one.
  String? _problemProperty(String name) {
    final data = response?.data;

    if (data is! Map) return null;

    final value = data[name];

    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }
}

// The text to show for a failure that reached the UI, in the language of [t].
extension FailureMessage on Object? {
  String userMessage(Translations t) => switch (this) {
    final AppException error => error.localizedMessage(t),
    final DioException error => error.toAppException().localizedMessage(t),
    final value? => value.toString(),
    _ => '',
  };
}

extension AppExceptionMessage on AppException {
  // The wording of the failure in the language of [t]: the translated name of
  // its code, or the message it carries when the code cannot name it.
  String localizedMessage(Translations t) =>
      code?.localizedMessage(t) ?? message;
}

extension AppErrorCodeMessage on AppErrorCode {
  // The wording of this failure in the language of [t].
  String localizedMessage(Translations t) => switch (this) {
    AppErrorCode.network => t.errors.network,
    AppErrorCode.timeout => t.errors.timeout,
    AppErrorCode.cancelled => t.errors.cancelled,
    AppErrorCode.unauthorized => t.errors.unauthorized,
    AppErrorCode.forbidden => t.errors.forbidden,
    AppErrorCode.notFound => t.errors.notFound,
    AppErrorCode.conflict => t.errors.conflict,
    AppErrorCode.validation => t.errors.validation,
    AppErrorCode.badRequest => t.errors.badRequest,
    AppErrorCode.server => t.errors.server,
    AppErrorCode.unknown => t.errors.unknown,
    AppErrorCode.signingIn => t.errors.signingIn,
    AppErrorCode.studentNameRequired => t.errors.studentNameRequired,
    AppErrorCode.groupNameRequired => t.errors.groupNameRequired,
    AppErrorCode.invalidPrice => t.errors.invalidPrice,
    AppErrorCode.studentNameNotUnique => t.errors.studentNameNotUnique,
    AppErrorCode.groupNameNotUnique => t.errors.groupNameNotUnique,
  };
}

Future<T> guardApiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw error.toAppException();
  }
}
