// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentSummaryResponse _$StudentSummaryResponseFromJson(
  Map<String, dynamic> json,
) => StudentSummaryResponse(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => StudentStatus.fromJson(e as String))
      .toList(),
  birthdate: json['birthdate'] == null
      ? null
      : DateTime.parse(json['birthdate'] as String),
  phone: json['phone'] as String?,
  note: json['note'] as String?,
  studentGroup: json['studentGroup'] == null
      ? null
      : GroupResponse.fromJson(json['studentGroup'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StudentSummaryResponseToJson(
  StudentSummaryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'birthdate': instance.birthdate?.toIso8601String(),
  'phone': instance.phone,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'studentGroup': instance.studentGroup,
  'statuses': instance.statuses.map((e) => _$StudentStatusEnumMap[e]!).toList(),
};

const _$StudentStatusEnumMap = {
  StudentStatus.inactive: 'INACTIVE',
  StudentStatus.present: 'PRESENT',
  StudentStatus.missing: 'MISSING',
  StudentStatus.paid: 'PAID',
  StudentStatus.unpaid: 'UNPAID',
  StudentStatus.$unknown: r'$unknown',
};
