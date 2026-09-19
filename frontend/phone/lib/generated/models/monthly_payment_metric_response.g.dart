// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_payment_metric_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyPaymentMetricResponse _$MonthlyPaymentMetricResponseFromJson(
  Map<String, dynamic> json,
) => MonthlyPaymentMetricResponse(
  date: json['date'] as String,
  total: json['total'] as num,
);

Map<String, dynamic> _$MonthlyPaymentMetricResponseToJson(
  MonthlyPaymentMetricResponse instance,
) => <String, dynamic>{'date': instance.date, 'total': instance.total};
