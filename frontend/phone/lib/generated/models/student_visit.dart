// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_visit_status.dart';
import 'student_visit_type.dart';

part 'student_visit.g.dart';

@JsonSerializable()
class StudentVisit {
  const StudentVisit({this.studentId, this.status, this.type});

  factory StudentVisit.fromJson(Map<String, Object?> json) =>
      _$StudentVisitFromJson(json);

  final String? studentId;
  final StudentVisitStatus? status;
  final StudentVisitType? type;

  Map<String, Object?> toJson() => _$StudentVisitToJson(this);
}
