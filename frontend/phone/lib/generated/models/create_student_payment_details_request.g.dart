// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_student_payment_details_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStudentPaymentDetailsRequest _$CreateStudentPaymentDetailsRequestFromJson(
  Map<String, dynamic> json,
) => CreateStudentPaymentDetailsRequest(
  detailsType: json['detailsType'] as String,
  studentId: json['studentId'] as String,
  paidUntil: DateTime.parse(json['paidUntil'] as String),
  paidFrom: DateTime.parse(json['paidFrom'] as String),
);

Map<String, dynamic> _$CreateStudentPaymentDetailsRequestToJson(
  CreateStudentPaymentDetailsRequest instance,
) => <String, dynamic>{
  'detailsType': instance.detailsType,
  'studentId': instance.studentId,
  'paidUntil': instance.paidUntil.toIso8601String(),
  'paidFrom': instance.paidFrom.toIso8601String(),
};
