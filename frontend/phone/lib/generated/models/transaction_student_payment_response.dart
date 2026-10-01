// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'transaction_student_payment_response.g.dart';

@JsonSerializable()
class TransactionStudentPaymentResponse {
  const TransactionStudentPaymentResponse({
    required this.id,
    required this.fullName,
    required this.createdAt,
    required this.paidUntil,
    this.birthdate,
    this.phone,
    this.note,
  });

  factory TransactionStudentPaymentResponse.fromJson(
    Map<String, Object?> json,
  ) => _$TransactionStudentPaymentResponseFromJson(json);

  final String id;
  final String fullName;
  final DateTime? birthdate;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final DateTime paidUntil;

  Map<String, Object?> toJson() =>
      _$TransactionStudentPaymentResponseToJson(this);
}
