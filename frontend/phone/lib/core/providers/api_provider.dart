import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/token_provider.dart';

const _timeout = Duration(seconds: kDebugMode ? 5 : 30);

final apiProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: kDebugMode ? 'http://10.0.2.2:8080' : 'https://trenero.org',
      headers: {'Content-Type': 'application/json'},
      receiveTimeout: _timeout,
      connectTimeout: _timeout,
      sendTimeout: _timeout,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = ref.read(tokenProvider);

        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
