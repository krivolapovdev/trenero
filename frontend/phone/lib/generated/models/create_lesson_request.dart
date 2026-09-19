// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_visit.dart';

part 'create_lesson_request.g.dart';

@JsonSerializable()
class CreateLessonRequest {
  const CreateLessonRequest({
    required this.groupId,
    required this.date,
    this.students,
  });

  factory CreateLessonRequest.fromJson(Map<String, Object?> json) =>
      _$CreateLessonRequestFromJson(json);

  final String groupId;
  final DateTime date;
  final List<StudentVisit>? students;

  Map<String, Object?> toJson() => _$CreateLessonRequestToJson(this);
}
