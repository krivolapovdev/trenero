// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lesson_response.g.dart';

@JsonSerializable()
class LessonResponse {
  const LessonResponse({
    required this.id,
    required this.groupId,
    required this.date,
    required this.createdAt,
  });

  factory LessonResponse.fromJson(Map<String, Object?> json) =>
      _$LessonResponseFromJson(json);

  final String id;
  final String groupId;
  final DateTime date;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$LessonResponseToJson(this);
}
