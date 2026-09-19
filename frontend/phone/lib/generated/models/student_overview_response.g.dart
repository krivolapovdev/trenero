// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_overview_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentOverviewResponse _$StudentOverviewResponseFromJson(
  Map<String, dynamic> json,
) => StudentOverviewResponse(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => StudentOverviewResponseStatuses.fromJson(e as String))
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

Map<String, dynamic> _$StudentOverviewResponseToJson(
  StudentOverviewResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'birthdate': instance.birthdate?.toIso8601String(),
  'phone': instance.phone,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'studentGroup': instance.studentGroup,
  'statuses': instance.statuses
      .map((e) => _$StudentOverviewResponseStatusesEnumMap[e]!)
      .toList(),
};

const _$StudentOverviewResponseStatusesEnumMap = {
  StudentOverviewResponseStatuses.inactive: 'INACTIVE',
  StudentOverviewResponseStatuses.present: 'PRESENT',
  StudentOverviewResponseStatuses.missing: 'MISSING',
  StudentOverviewResponseStatuses.paid: 'PAID',
  StudentOverviewResponseStatuses.unpaid: 'UNPAID',
  StudentOverviewResponseStatuses.$unknown: r'$unknown',
};
