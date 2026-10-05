// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_payment_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentPaymentDetailsResponse _$StudentPaymentDetailsResponseFromJson(
  Map<String, dynamic> json,
) => StudentPaymentDetailsResponse(
  detailsType: json['detailsType'] as String,
  studentId: json['studentId'] as String,
  paidUntil: DateTime.parse(json['paidUntil'] as String),
  paidFrom: DateTime.parse(json['paidFrom'] as String),
  studentName: json['studentName'] as String,
);

Map<String, dynamic> _$StudentPaymentDetailsResponseToJson(
  StudentPaymentDetailsResponse instance,
) => <String, dynamic>{
  'detailsType': instance.detailsType,
  'studentId': instance.studentId,
  'paidUntil': instance.paidUntil.toIso8601String(),
  'paidFrom': instance.paidFrom.toIso8601String(),
  'studentName': instance.studentName,
};
