// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'visit_response.dart';

part 'lesson_details_response.g.dart';

@JsonSerializable()
class LessonDetailsResponse {
  const LessonDetailsResponse({
    required this.id,
    required this.groupId,
    required this.date,
    required this.createdAt,
    required this.studentVisits,
  });

  factory LessonDetailsResponse.fromJson(Map<String, Object?> json) =>
      _$LessonDetailsResponseFromJson(json);

  final String id;
  final String groupId;
  final DateTime date;
  final DateTime createdAt;
  final List<VisitResponse> studentVisits;

  Map<String, Object?> toJson() => _$LessonDetailsResponseToJson(this);
}
