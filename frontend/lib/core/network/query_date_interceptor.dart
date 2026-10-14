import 'package:dio/dio.dart';
import 'package:phone/core/extensions/date_time_extension.dart';

/// Appends the local timezone offset to query parameters carrying a local ISO timestamp
/// without an offset, matching API `OffsetDateTime` query requirements.
class QueryDateInterceptor extends Interceptor {
  const new();

  static final RegExp _deviceTimestamp = RegExp(
    r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?$',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.queryParameters.isNotEmpty) {
      options.queryParameters = <String, dynamic>{
        for (final entry in options.queryParameters.entries)
          entry.key: entry.value is String &&
                  _deviceTimestamp.hasMatch(entry.value as String)
              ? '${entry.value}${DateTime.parse(entry.value as String).timeZoneOffsetFormatted}'
              : entry.value,
      };
    }

    handler.next(options);
  }
}
