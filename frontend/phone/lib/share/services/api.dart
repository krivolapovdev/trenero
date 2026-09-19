import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final Dio api = Dio(
  BaseOptions(
    baseUrl: kDebugMode ? 'http://10.0.2.2:8080' : 'https://trenero.org',
    headers: {'Content-Type': 'application/json'},
  ),
);
