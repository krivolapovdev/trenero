// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum StudentOverviewResponseStatuses {
  @JsonValue('INACTIVE')
  inactive('INACTIVE'),
  @JsonValue('PRESENT')
  present('PRESENT'),
  @JsonValue('MISSING')
  missing('MISSING'),
  @JsonValue('PAID')
  paid('PAID'),
  @JsonValue('UNPAID')
  unpaid('UNPAID'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const StudentOverviewResponseStatuses(this.json);

  factory StudentOverviewResponseStatuses.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<StudentOverviewResponseStatuses> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
