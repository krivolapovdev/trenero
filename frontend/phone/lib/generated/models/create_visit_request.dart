// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_visit_request_status.dart';
import 'create_visit_request_type.dart';

part 'create_visit_request.g.dart';

@JsonSerializable()
class CreateVisitRequest {
  const CreateVisitRequest({
    required this.lessonId,
    required this.studentId,
    required this.status,
    required this.type,
  });

  factory CreateVisitRequest.fromJson(Map<String, Object?> json) =>
      _$CreateVisitRequestFromJson(json);

  final String lessonId;
  final String studentId;
  final CreateVisitRequestStatus status;
  final CreateVisitRequestType type;

  Map<String, Object?> toJson() => _$CreateVisitRequestToJson(this);
}
