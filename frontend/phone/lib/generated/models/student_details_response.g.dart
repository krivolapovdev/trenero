// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDetailsResponse _$StudentDetailsResponseFromJson(
  Map<String, dynamic> json,
) => StudentDetailsResponse(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  studentVisits: (json['studentVisits'] as List<dynamic>)
      .map((e) => VisitWithLessonResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  studentPayments: (json['studentPayments'] as List<dynamic>)
      .map((e) => StudentPaymentResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  statuses: (json['statuses'] as List<dynamic>)
      .map((e) => StudentDetailsResponseStatuses.fromJson(e as String))
      .toList(),
  birthdate: json['birthdate'] == null
      ? null
      : DateTime.parse(json['birthdate'] as String),
  phone: json['phone'] as String?,
  note: json['note'] as String?,
  studentGroup: json['studentGroup'] == null
      ? null
      : GroupResponse.fromJson(json['studentGroup'] as Map<String, dynamic>),
  groupStudentResponse: json['groupStudentResponse'] == null
      ? null
      : GroupStudentResponse.fromJson(
          json['groupStudentResponse'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$StudentDetailsResponseToJson(
  StudentDetailsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'birthdate': instance.birthdate?.toIso8601String(),
  'phone': instance.phone,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
  'studentVisits': instance.studentVisits,
  'studentPayments': instance.studentPayments,
  'statuses': instance.statuses
      .map((e) => _$StudentDetailsResponseStatusesEnumMap[e]!)
      .toList(),
  'studentGroup': instance.studentGroup,
  'groupStudentResponse': instance.groupStudentResponse,
};

const _$StudentDetailsResponseStatusesEnumMap = {
  StudentDetailsResponseStatuses.inactive: 'INACTIVE',
  StudentDetailsResponseStatuses.present: 'PRESENT',
  StudentDetailsResponseStatuses.missing: 'MISSING',
  StudentDetailsResponseStatuses.paid: 'PAID',
  StudentDetailsResponseStatuses.unpaid: 'UNPAID',
  StudentDetailsResponseStatuses.$unknown: r'$unknown',
};
