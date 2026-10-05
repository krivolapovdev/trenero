// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_student_payment_details_request.g.dart';

@JsonSerializable()
class CreateStudentPaymentDetailsRequest {
  const CreateStudentPaymentDetailsRequest({
    required this.detailsType,
    required this.studentId,
    required this.paidUntil,
    required this.paidFrom,
  });

  factory CreateStudentPaymentDetailsRequest.fromJson(
    Map<String, Object?> json,
  ) => _$CreateStudentPaymentDetailsRequestFromJson(json);

  final String detailsType;
  final String studentId;
  final DateTime paidUntil;
  final DateTime paidFrom;

  Map<String, Object?> toJson() =>
      _$CreateStudentPaymentDetailsRequestToJson(this);
}
