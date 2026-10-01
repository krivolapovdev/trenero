// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_response.dart';
import 'student_response.dart';

part 'group_details.g.dart';

@JsonSerializable()
class GroupDetails {
  const GroupDetails({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.groupStudents,
    required this.groupLessons,
    this.defaultPrice,
    this.note,
  });

  factory GroupDetails.fromJson(Map<String, Object?> json) =>
      _$GroupDetailsFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;
  final List<StudentResponse> groupStudents;
  final List<LessonResponse> groupLessons;

  Map<String, Object?> toJson() => _$GroupDetailsToJson(this);
}
