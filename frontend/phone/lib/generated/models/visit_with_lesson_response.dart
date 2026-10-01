// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'lesson_response.dart';
import 'visit_response.dart';

part 'visit_with_lesson_response.g.dart';

@JsonSerializable()
class VisitWithLessonResponse {
  const VisitWithLessonResponse({required this.visit, required this.lesson});

  factory VisitWithLessonResponse.fromJson(Map<String, Object?> json) =>
      _$VisitWithLessonResponseFromJson(json);

  final VisitResponse visit;
  final LessonResponse lesson;

  Map<String, Object?> toJson() => _$VisitWithLessonResponseToJson(this);
}
