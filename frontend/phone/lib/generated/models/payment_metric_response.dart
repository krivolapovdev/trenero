// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'payment_metric_response.g.dart';

@JsonSerializable()
class PaymentMetricResponse {
  const PaymentMetricResponse({required this.date, required this.total});

  factory PaymentMetricResponse.fromJson(Map<String, Object?> json) =>
      _$PaymentMetricResponseFromJson(json);

  final DateTime date;
  final num total;

  Map<String, Object?> toJson() => _$PaymentMetricResponseToJson(this);
}
