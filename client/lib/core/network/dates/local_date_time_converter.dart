import 'package:json_annotation/json_annotation.dart';
import 'package:phone/core/extensions/date_time_extension.dart';

/// Serializes moments with the device region's offset and deserializes them into the device's local time.
///
/// Handled automatically by `json_serializable` for both [DateTime] and [DateTime?].
class LocalDateTimeConverter implements JsonConverter<DateTime, String> {
  const new();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime date) => date.toIso8601StringWithOffset();
}

/// Serializes calendar days as `yyyy-MM-dd` (e.g. for plain dates like `birthdate`).
///
/// Handled automatically by `json_serializable` for both [DateTime] and [DateTime?].
class LocalDateConverter implements JsonConverter<DateTime, String> {
  const new();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime date) => date.toIsoDateString();
}
