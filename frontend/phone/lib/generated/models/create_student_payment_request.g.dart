// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_student_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStudentPaymentRequest _$CreateStudentPaymentRequestFromJson(
  Map<String, dynamic> json,
) => CreateStudentPaymentRequest(
  studentId: json['studentId'] as String,
  amount: json['amount'] as num,
  date: DateTime.parse(json['date'] as String),
  paidUntil: DateTime.parse(json['paidUntil'] as String),
);

Map<String, dynamic> _$CreateStudentPaymentRequestToJson(
  CreateStudentPaymentRequest instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'paidUntil': instance.paidUntil.toIso8601String(),
};
