import 'package:dio/dio.dart';
import 'package:phone/core/errors/app_exception.dart';

extension DioExceptionMapper on DioException {
  AppException toAppException() => switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => RequestTimeoutException(cause: this),
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate => NetworkException(cause: this),
    DioExceptionType.cancel => RequestCancelledException(cause: this),
    DioExceptionType.badResponse => _fromStatusCode(),
    DioExceptionType.unknown => UnknownException(cause: this),
  };

  AppException _fromStatusCode() {
    final statusCode = response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException(cause: this);
    }

    return ServerException(statusCode: statusCode, cause: this);
  }
}

Future<T> guardApiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw error.toAppException();
  }
}
