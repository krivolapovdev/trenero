// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_payment_request.g.dart';

@JsonSerializable()
class UpdatePaymentRequest {
  const UpdatePaymentRequest({this.amount, this.paidUntil, this.date});

  factory UpdatePaymentRequest.fromJson(Map<String, Object?> json) =>
      _$UpdatePaymentRequestFromJson(json);

  final num? amount;
  final DateTime? paidUntil;
  final DateTime? date;

  Map<String, Object?> toJson() => _$UpdatePaymentRequestToJson(this);
}
