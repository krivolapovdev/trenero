// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_status.dart';

part 'group_student_summary_response.g.dart';

@JsonSerializable()
class GroupStudentSummaryResponse {
  const GroupStudentSummaryResponse({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.statuses,
    this.birthdate,
    this.phone,
    this.note,
  });

  factory GroupStudentSummaryResponse.fromJson(Map<String, Object?> json) =>
      _$GroupStudentSummaryResponseFromJson(json);

  final String id;
  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final List<StudentStatus> statuses;

  Map<String, Object?> toJson() => _$GroupStudentSummaryResponseToJson(this);
}
