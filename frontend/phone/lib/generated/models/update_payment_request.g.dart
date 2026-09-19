// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePaymentRequest _$UpdatePaymentRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePaymentRequest(
  amount: json['amount'] as num?,
  paidUntil: json['paidUntil'] == null
      ? null
      : DateTime.parse(json['paidUntil'] as String),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$UpdatePaymentRequestToJson(
  UpdatePaymentRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'paidUntil': instance.paidUntil?.toIso8601String(),
  'date': instance.date?.toIso8601String(),
};
