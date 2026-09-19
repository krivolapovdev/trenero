// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'create_transaction_request_type.dart';

part 'create_transaction_request.g.dart';

@JsonSerializable()
class CreateTransactionRequest {
  const CreateTransactionRequest({
    required this.amount,
    required this.type,
    required this.date,
  });

  factory CreateTransactionRequest.fromJson(Map<String, Object?> json) =>
      _$CreateTransactionRequestFromJson(json);

  final num amount;
  final CreateTransactionRequestType type;
  final DateTime date;

  Map<String, Object?> toJson() => _$CreateTransactionRequestToJson(this);
}
