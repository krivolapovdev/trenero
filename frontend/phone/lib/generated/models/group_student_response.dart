// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_student_response.g.dart';

@JsonSerializable()
class GroupStudentResponse {
  const GroupStudentResponse({
    required this.id,
    required this.groupId,
    required this.studentId,
    this.leftAt,
  });

  factory GroupStudentResponse.fromJson(Map<String, Object?> json) =>
      _$GroupStudentResponseFromJson(json);

  final String id;
  final String groupId;
  final String studentId;
  final DateTime? leftAt;

  Map<String, Object?> toJson() => _$GroupStudentResponseToJson(this);
}
