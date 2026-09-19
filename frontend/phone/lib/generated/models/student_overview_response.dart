// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_response.dart';
import 'student_overview_response_statuses.dart';

part 'student_overview_response.g.dart';

@JsonSerializable()
class StudentOverviewResponse {
  const StudentOverviewResponse({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.statuses,
    this.birthdate,
    this.phone,
    this.note,
    this.studentGroup,
  });

  factory StudentOverviewResponse.fromJson(Map<String, Object?> json) =>
      _$StudentOverviewResponseFromJson(json);

  final String id;
  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final GroupResponse? studentGroup;
  final List<StudentOverviewResponseStatuses> statuses;

  Map<String, Object?> toJson() => _$StudentOverviewResponseToJson(this);
}
