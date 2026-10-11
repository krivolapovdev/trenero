import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:phone/core/storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  new({
    required this._refreshClient,
    required this._retryClient,
    required this._tokenStorage,
  });

  static const String refreshPath = '/api/v1/jwt/refresh';

  static const String _authorizationHeader = 'Authorization';

  final Dio _refreshClient;

  final Dio _retryClient;

  final TokenStorage _tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _tokenStorage.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[_authorizationHeader] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshRequest(err) || !_isUnauthorized(err)) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      handler.resolve(await _replayWithFreshTokens(err, refreshToken));
    } catch (refreshError) {
      log('Token refresh failed: $refreshError');
      await _tokenStorage.clear();
      handler.next(err);
    }
  }

  bool _isRefreshRequest(DioException error) =>
      error.requestOptions.path.contains(refreshPath);

  bool _isUnauthorized(DioException error) {
    final statusCode = error.response?.statusCode;

    return statusCode == 401 || statusCode == 403;
  }

  Future<Response<dynamic>> _replayWithFreshTokens(
    DioException error,
    String refreshToken,
  ) async {
    final response = await _refreshClient.post(
      refreshPath,
      data: {'refreshToken': refreshToken},
    );

    final newAccessToken = response.data['accessToken'] as String;
    final newRefreshToken = response.data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    final options = error.requestOptions;
    options.headers[_authorizationHeader] = 'Bearer $newAccessToken';

    return _retryClient.fetch(options);
  }
}
