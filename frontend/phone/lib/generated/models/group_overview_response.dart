// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_response.dart';

part 'group_overview_response.g.dart';

@JsonSerializable()
class GroupOverviewResponse {
  const GroupOverviewResponse({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.groupStudents,
    this.defaultPrice,
    this.note,
  });

  factory GroupOverviewResponse.fromJson(Map<String, Object?> json) =>
      _$GroupOverviewResponseFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;
  final List<StudentResponse> groupStudents;

  Map<String, Object?> toJson() => _$GroupOverviewResponseToJson(this);
}
