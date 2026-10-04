// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_metric_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMetricResponse _$PaymentMetricResponseFromJson(
  Map<String, dynamic> json,
) => PaymentMetricResponse(
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  total: json['total'] as num?,
);

Map<String, dynamic> _$PaymentMetricResponseToJson(
  PaymentMetricResponse instance,
) => <String, dynamic>{
  'date': instance.date?.toIso8601String(),
  'total': instance.total,
};
