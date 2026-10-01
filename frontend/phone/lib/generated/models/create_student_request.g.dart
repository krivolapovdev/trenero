// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_student_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateStudentRequest _$CreateStudentRequestFromJson(
  Map<String, dynamic> json,
) => CreateStudentRequest(
  fullName: json['fullName'] as String,
  birthdate: json['birthdate'] == null
      ? null
      : DateTime.parse(json['birthdate'] as String),
  phone: json['phone'] as String?,
  note: json['note'] as String?,
  groupId: json['groupId'] as String?,
);

Map<String, dynamic> _$CreateStudentRequestToJson(
  CreateStudentRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'birthdate': instance.birthdate?.toIso8601String(),
  'phone': instance.phone,
  'note': instance.note,
  'groupId': instance.groupId,
};
