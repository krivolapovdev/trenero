extension DateTimeExtension on DateTime {
  /// The timezone offset formatted as `+HH:MM` or `-HH:MM`.
  String get timeZoneOffsetFormatted {
    final offset = timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }

  /// ISO-8601 string including local timezone offset.
  ///
  /// Local: `2026-10-14T23:18:56.000+05:00`
  /// UTC: `2026-10-14T18:18:56.000Z`
  String toIso8601StringWithOffset() {
    final iso = toIso8601String();
    if (isUtc) return iso;
    return '$iso$timeZoneOffsetFormatted';
  }

  /// Calendar day formatted as `yyyy-MM-dd`.
  /// Example: `2026-10-14`
  String toIsoDateString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
