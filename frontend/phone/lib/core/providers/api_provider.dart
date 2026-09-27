import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/storage/token_storage.dart';

const _timeout = Duration(seconds: kDebugMode ? 5 : 30);
const _baseUrl = kDebugMode ? 'http://10.0.2.2:8080' : 'https://trenero.org';

final unauthenticatedDioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: _timeout,
      connectTimeout: _timeout,
      sendTimeout: _timeout,
    ),
  ),
);

final apiProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final rawDio = ref.watch(unauthenticatedDioProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: _timeout,
      connectTimeout: _timeout,
      sendTimeout: _timeout,
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = tokenStorage.accessToken;

        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        return handler.next(options);
      },

      onError: (DioException error, handler) async {
        if (error.requestOptions.path.contains('/jwt/refresh')) {
          return handler.next(error);
        }

        if (error.response?.statusCode == 401 ||
            error.response?.statusCode == 403) {
          final refreshToken = await tokenStorage.getRefreshToken();

          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final response = await rawDio.post(
                '/api/v1/jwt/refresh',
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;

              await tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';

              final clonedResponse = await dio.fetch(opts);
              return handler.resolve(clonedResponse);
            } catch (e) {
              log('Token refresh failed: $e');
              await tokenStorage.clear();
            }
          }
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
});
