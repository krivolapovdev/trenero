// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_student_request.g.dart';

@JsonSerializable()
class CreateStudentRequest {
  const CreateStudentRequest({
    required this.fullName,
    this.birthdate,
    this.phone,
    this.note,
    this.groupId,
  });

  factory CreateStudentRequest.fromJson(Map<String, Object?> json) =>
      _$CreateStudentRequestFromJson(json);

  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final String? groupId;

  Map<String, Object?> toJson() => _$CreateStudentRequestToJson(this);
}
