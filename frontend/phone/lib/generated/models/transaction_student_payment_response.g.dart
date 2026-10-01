// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_student_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionStudentPaymentResponse _$TransactionStudentPaymentResponseFromJson(
  Map<String, dynamic> json,
) => TransactionStudentPaymentResponse(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  paidUntil: DateTime.parse(json['paidUntil'] as String),
  birthdate: json['birthdate'] == null
      ? null
      : DateTime.parse(json['birthdate'] as String),
  phone: json['phone'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$TransactionStudentPaymentResponseToJson(
  TransactionStudentPaymentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'birthdate': instance.birthdate?.toIso8601String(),
  'phone': instance.phone,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'paidUntil': instance.paidUntil.toIso8601String(),
};
