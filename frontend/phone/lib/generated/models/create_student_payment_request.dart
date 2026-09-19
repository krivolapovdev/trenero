// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_student_payment_request.g.dart';

@JsonSerializable()
class CreateStudentPaymentRequest {
  const CreateStudentPaymentRequest({
    required this.studentId,
    required this.amount,
    required this.date,
    required this.paidUntil,
  });

  factory CreateStudentPaymentRequest.fromJson(Map<String, Object?> json) =>
      _$CreateStudentPaymentRequestFromJson(json);

  final String studentId;
  final num amount;
  final DateTime date;
  final DateTime paidUntil;

  Map<String, Object?> toJson() => _$CreateStudentPaymentRequestToJson(this);
}
