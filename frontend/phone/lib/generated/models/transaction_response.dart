// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'transaction_response_type.dart';
import 'transaction_student_payment_response.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  const TransactionResponse({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.createdAt,
    this.studentPayment,
  });

  factory TransactionResponse.fromJson(Map<String, Object?> json) =>
      _$TransactionResponseFromJson(json);

  final String id;
  final num amount;
  final DateTime date;
  final TransactionResponseType type;
  final DateTime createdAt;
  final TransactionStudentPaymentResponse? studentPayment;

  Map<String, Object?> toJson() => _$TransactionResponseToJson(this);
}
