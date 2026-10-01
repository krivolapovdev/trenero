// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'visit_response_status.dart';
import 'visit_response_type.dart';

part 'visit_response.g.dart';

@JsonSerializable()
class VisitResponse {
  const VisitResponse({
    required this.id,
    required this.status,
    required this.type,
    required this.lessonId,
    required this.studentId,
    required this.createdAt,
  });

  factory VisitResponse.fromJson(Map<String, Object?> json) =>
      _$VisitResponseFromJson(json);

  final String id;
  final VisitResponseStatus status;
  final VisitResponseType type;
  final String lessonId;
  final String studentId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$VisitResponseToJson(this);
}
