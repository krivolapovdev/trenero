// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_student_payment_details_request.dart';
import 'transaction_type.dart';

part 'create_transaction_request.g.dart';

@JsonSerializable()
class CreateTransactionRequest {
  const CreateTransactionRequest({
    required this.amount,
    required this.date,
    required this.type,
    this.paymentDetails,
  });

  factory CreateTransactionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateTransactionRequestFromJson(json);

  final num amount;
  final DateTime date;
  final TransactionType type;
  final CreateStudentPaymentDetailsRequest? paymentDetails;

  Map<String, Object?> toJson() => _$CreateTransactionRequestToJson(this);
}
