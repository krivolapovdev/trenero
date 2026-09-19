// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'student_response.g.dart';

@JsonSerializable()
class StudentResponse {
  const StudentResponse({
    required this.id,
    required this.fullName,
    required this.createdAt,
    this.birthdate,
    this.phone,
    this.note,
  });

  factory StudentResponse.fromJson(Map<String, Object?> json) =>
      _$StudentResponseFromJson(json);

  final String id;
  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$StudentResponseToJson(this);
}
