import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/config/app_environment.dart';
import 'package:phone/core/network/auth_interceptor.dart';
import 'package:phone/core/network/query_date_interceptor.dart';
import 'package:phone/core/network/response_log_interceptor.dart';
import 'package:phone/core/storage/token_storage.dart';

final unauthenticatedDioProvider = Provider<Dio>(
  (ref) => Dio(_baseOptions())..interceptors.add(const QueryDateInterceptor()),
);

final apiProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final refreshClient = ref.watch(unauthenticatedDioProvider);

  final dio = Dio(_baseOptions())
    ..interceptors.add(const QueryDateInterceptor());

  dio.interceptors.add(
    AuthInterceptor(
      refreshClient: refreshClient,
      retryClient: dio,
      tokenStorage: tokenStorage,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(const ResponseLogInterceptor());
  }

  return dio;
});

BaseOptions _baseOptions() => BaseOptions(
  baseUrl: AppEnvironment.baseUrl,
  headers: const {'Content-Type': 'application/json'},
  receiveTimeout: AppEnvironment.receiveTimeout,
  connectTimeout: AppEnvironment.connectTimeout,
  sendTimeout: AppEnvironment.sendTimeout,
);
