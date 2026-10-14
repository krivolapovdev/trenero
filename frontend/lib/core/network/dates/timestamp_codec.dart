/// The two shapes a timestamp of the API has: the one the device writes and the one the API writes.
abstract interface class TimestampCodec {
  /// The API shape of a timestamp of the device: the wall clock of the device together with the
  /// offset of the region it is in, for example `2026-10-08T00:00:00.000+03:00`.
  ///
  /// A value that is not a timestamp of the device is returned unchanged.
  String toApi(String value);

  /// The device shape of a timestamp of the API: the wall clock of the device without an offset,
  /// which is the local time that `DateTime.parse` reads out of it.
  ///
  /// A value that is not a timestamp of the API is returned unchanged.
  String toDevice(String value);
}

/// A [TimestampCodec] for ISO-8601 timestamps.
final class IsoTimestampCodec implements TimestampCodec {
  const new();

  static final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static final RegExp _deviceTimestamp = RegExp(
    r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?$',
  );

  static final RegExp _apiTimestamp = RegExp(
    r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:?\d{2})$',
  );

  @override
  String toApi(String value) {
    if (_day.hasMatch(value)) {
      final day = DateTime.parse(value);

      return '${day.toIso8601String()}${_offsetOf(day)}';
    }

    if (_deviceTimestamp.hasMatch(value)) {
      return '$value${_offsetOf(DateTime.parse(value))}';
    }

    return value;
  }

  @override
  String toDevice(String value) => _apiTimestamp.hasMatch(value)
      ? DateTime.parse(value).toLocal().toIso8601String()
      : value;

  /// The `+HH:MM` the region of the device sits at, at the given local time.
  static String _offsetOf(DateTime local) {
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return '$sign$hours:$minutes';
  }
}
