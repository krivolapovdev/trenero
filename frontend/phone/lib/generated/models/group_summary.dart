// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_response.dart';

part 'group_summary.g.dart';

@JsonSerializable()
class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.groupStudents,
    this.defaultPrice,
    this.note,
  });

  factory GroupSummary.fromJson(Map<String, Object?> json) =>
      _$GroupSummaryFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;
  final List<StudentResponse> groupStudents;

  Map<String, Object?> toJson() => _$GroupSummaryToJson(this);
}
