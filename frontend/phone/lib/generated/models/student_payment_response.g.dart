// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentPaymentResponse _$StudentPaymentResponseFromJson(
  Map<String, dynamic> json,
) => StudentPaymentResponse(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  amount: json['amount'] as num,
  date: DateTime.parse(json['date'] as String),
  paidUntil: DateTime.parse(json['paidUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  paidFrom: json['paidFrom'] == null
      ? null
      : DateTime.parse(json['paidFrom'] as String),
);

Map<String, dynamic> _$StudentPaymentResponseToJson(
  StudentPaymentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'paidFrom': instance.paidFrom?.toIso8601String(),
  'paidUntil': instance.paidUntil.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
