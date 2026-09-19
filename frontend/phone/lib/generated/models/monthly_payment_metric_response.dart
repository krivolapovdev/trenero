// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'monthly_payment_metric_response.g.dart';

@JsonSerializable()
class MonthlyPaymentMetricResponse {
  const MonthlyPaymentMetricResponse({required this.date, required this.total});

  factory MonthlyPaymentMetricResponse.fromJson(Map<String, Object?> json) =>
      _$MonthlyPaymentMetricResponseFromJson(json);

  final String date;
  final num total;

  Map<String, Object?> toJson() => _$MonthlyPaymentMetricResponseToJson(this);
}
