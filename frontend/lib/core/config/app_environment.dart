import 'package:flutter/foundation.dart';

abstract final class AppEnvironment {
  static const String baseUrl = kDebugMode
      ? 'http://192.168.1.4:8080'
      : 'https://api.trenerio.ru';

  static const Duration connectTimeout = Duration(seconds: kDebugMode ? 5 : 10);
  static const Duration receiveTimeout = Duration(seconds: kDebugMode ? 5 : 15);
  static const Duration sendTimeout = Duration(seconds: 60);
}
