// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'student_payment_response.g.dart';

@JsonSerializable()
class StudentPaymentResponse {
  const StudentPaymentResponse({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.paidUntil,
    required this.createdAt,
    this.paidFrom,
  });

  factory StudentPaymentResponse.fromJson(Map<String, Object?> json) =>
      _$StudentPaymentResponseFromJson(json);

  final String id;
  final String studentId;
  final num amount;
  final DateTime date;
  final DateTime? paidFrom;
  final DateTime paidUntil;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$StudentPaymentResponseToJson(this);
}
