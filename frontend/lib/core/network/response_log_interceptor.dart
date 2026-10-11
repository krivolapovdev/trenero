import 'dart:developer';

import 'package:dio/dio.dart';

class ResponseLogInterceptor extends Interceptor {
  const new();

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log('Response [${response.statusCode}] => DATA: ${response.data}');
    handler.next(response);
  }
}
