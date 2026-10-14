import 'package:dio/dio.dart';

/// The API carries a day as an ISO-8601 timestamp with the offset of the region it belongs to,
/// while the app works with the local time of the device.
///
/// A day that leaves the app is stamped with the offset of the device region, so a payment recorded
/// just after midnight in a region ahead of the server stays on its own day instead of falling onto
/// the day before; a day that comes back is turned into the local time of the device, so the screens
/// keep reading the day of the user out of it.
class ApiDateInterceptor extends Interceptor {
  const new();

  /// The fields the API carries as a point in time.
  ///
  /// `birthdate` is deliberately absent: it is a plain calendar day and is sent as `yyyy-MM-dd`.
  static const Set<String> _timestamps = {
    'date',
    'paidUntil',
    'paidFrom',
    'createdAt',
    'updatedAt',
    'joinedAt',
    'leftAt',
  };

  static final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static final RegExp _localDateTime = RegExp(
    r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?$',
  );

  static final RegExp _offsetDateTime = RegExp(
    r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:?\d{2})$',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters = <String, dynamic>{
      for (final entry in options.queryParameters.entries)
        entry.key: _withRegionOffset(entry.value),
    };

    final data = options.data;
    if (data is Map) {
      _stampTimestamps(data);
    } else if (data != null) {
      final json = _asJson(data);
      if (json != null) {
        _stampTimestamps(json);
        options.data = json;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _toDeviceTime(response.data);
    handler.next(response);
  }

  /// Stamps every timestamp of a request body with the offset of the device region.
  void _stampTimestamps(Map<dynamic, dynamic> body) {
    for (final key in body.keys.toList()) {
      final value = body[key];

      if (value is Map) {
        _stampTimestamps(value);
      } else if (value is List) {
        for (final item in value) {
          if (item is Map) _stampTimestamps(item);
        }
      } else if (_timestamps.contains(key)) {
        body[key] = _withRegionOffset(value);
      }
    }
  }

  /// Writes the offset of the region of the value onto it: a plain day becomes the midnight of that
  /// day in that region, a local date time keeps its wall clock and gains the offset.
  Object? _withRegionOffset(Object? value) {
    if (value is! String) return value;

    if (_day.hasMatch(value)) {
      final day = DateTime.parse(value);
      return '${day.toIso8601String()}${_offsetSuffix(day.timeZoneOffset)}';
    }

    if (_localDateTime.hasMatch(value)) {
      final local = DateTime.parse(value);
      return '$value${_offsetSuffix(local.timeZoneOffset)}';
    }

    return value;
  }

  /// Turns every timestamp of a response into the local time of the device.
  Object? _toDeviceTime(Object? data) {
    if (data is Map) {
      for (final key in data.keys.toList()) {
        final value = data[key];

        if (value is Map || value is List) {
          data[key] = _toDeviceTime(value);
        } else if (value is String &&
            _timestamps.contains(key) &&
            _offsetDateTime.hasMatch(value)) {
          data[key] = DateTime.parse(value).toLocal().toIso8601String();
        }
      }

      return data;
    }

    if (data is List) {
      for (var index = 0; index < data.length; index++) {
        data[index] = _toDeviceTime(data[index]);
      }

      return data;
    }

    return data;
  }

  /// The wire shape of a request body, or `null` when the body is not JSON.
  Map<String, dynamic>? _asJson(Object data) {
    try {
      // ignore: avoid_dynamic_calls
      final json = (data as dynamic).toJson();

      return json is Map<String, dynamic> ? json : null;
    } on Object {
      return null;
    }
  }

  /// The `+HH:MM` an offset is written as in an ISO-8601 timestamp.
  static String _offsetSuffix(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return '$sign$hours:$minutes';
  }
}
