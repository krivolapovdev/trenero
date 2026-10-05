// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'student_payment_details_response.g.dart';

@JsonSerializable()
class StudentPaymentDetailsResponse {
  const StudentPaymentDetailsResponse({
    required this.detailsType,
    required this.studentId,
    required this.paidUntil,
    required this.paidFrom,
    required this.studentName,
  });

  factory StudentPaymentDetailsResponse.fromJson(Map<String, Object?> json) =>
      _$StudentPaymentDetailsResponseFromJson(json);

  final String detailsType;
  final String studentId;
  final DateTime paidUntil;
  final DateTime paidFrom;
  final String studentName;

  Map<String, Object?> toJson() => _$StudentPaymentDetailsResponseToJson(this);
}
