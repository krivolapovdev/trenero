// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'student_payment_details_response.dart';
import 'transaction_type.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  const TransactionResponse({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.createdAt,
    this.paymentDetails,
  });

  factory TransactionResponse.fromJson(Map<String, Object?> json) =>
      _$TransactionResponseFromJson(json);

  final String id;
  final num amount;
  final DateTime date;
  final TransactionType type;
  final DateTime createdAt;
  final StudentPaymentDetailsResponse? paymentDetails;

  Map<String, Object?> toJson() => _$TransactionResponseToJson(this);
}
