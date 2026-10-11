import 'package:flutter/foundation.dart';

abstract final class AppEnvironment {
  static const String baseUrl = kDebugMode
      ? 'http://192.168.1.4:8080'
      : 'https://trenerio.ru';

  static const Duration requestTimeout = Duration(seconds: kDebugMode ? 5 : 30);
}
