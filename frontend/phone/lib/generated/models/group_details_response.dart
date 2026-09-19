// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_response.dart';
import 'student_response.dart';

part 'group_details_response.g.dart';

@JsonSerializable()
class GroupDetailsResponse {
  const GroupDetailsResponse({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.groupStudents,
    required this.groupLessons,
    this.defaultPrice,
    this.note,
  });

  factory GroupDetailsResponse.fromJson(Map<String, Object?> json) =>
      _$GroupDetailsResponseFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;
  final List<StudentResponse> groupStudents;
  final List<LessonResponse> groupLessons;

  Map<String, Object?> toJson() => _$GroupDetailsResponseToJson(this);
}
