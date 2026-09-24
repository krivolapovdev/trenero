import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _timeout = Duration(seconds: kDebugMode ? 5_000 : 30_000);

final Dio api = Dio(
  BaseOptions(
    baseUrl: kDebugMode ? 'http://10.0.2.2:8080' : 'https://trenero.org',
    headers: {'Content-Type': 'application/json'},
    receiveTimeout: _timeout,
    connectTimeout: _timeout,
    sendTimeout: _timeout,
  ),
);
