// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_response.dart';
import 'group_student_response.dart';
import 'student_details_response_statuses.dart';
import 'student_payment_response.dart';
import 'visit_with_lesson_response.dart';

part 'student_details_response.g.dart';

@JsonSerializable()
class StudentDetailsResponse {
  const StudentDetailsResponse({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.studentVisits,
    required this.studentPayments,
    required this.statuses,
    this.birthdate,
    this.phone,
    this.note,
    this.studentGroup,
    this.groupStudentResponse,
  });

  factory StudentDetailsResponse.fromJson(Map<String, Object?> json) =>
      _$StudentDetailsResponseFromJson(json);

  final String id;
  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final List<VisitWithLessonResponse> studentVisits;
  final List<StudentPaymentResponse> studentPayments;
  final List<StudentDetailsResponseStatuses> statuses;
  final GroupResponse? studentGroup;
  final GroupStudentResponse? groupStudentResponse;

  Map<String, Object?> toJson() => _$StudentDetailsResponseToJson(this);
}
