import 'package:dio/dio.dart';
import 'package:phone/core/network/dates/datetime_mapper.dart';
import 'package:phone/core/network/dates/json_payload.dart';

class ApiDateInterceptor extends Interceptor {
  const new({
    this.mapper = const DateTimeMapper(),
    this.payload = const JsonPayloadCodec(),
  });

  final DateTimeMapper mapper;
  final JsonPayload payload;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters = <String, dynamic>{
      for (final entry in options.queryParameters.entries)
        entry.key: entry.value is String
            ? mapper.toApiValue(entry.value as String)
            : entry.value,
    };

    final body = payload.asJson(options.data);
    if (body != null) {
      options.data = mapper.toApi(body);
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    response.data = mapper.toDevice(response.data);

    handler.next(response);
  }
}
