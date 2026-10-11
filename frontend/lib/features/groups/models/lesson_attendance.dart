import 'package:flutter/foundation.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';

@immutable
class LessonAttendance {
  final VisitStatus status;
  final VisitType type;

  const new({required this.status, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAttendance && other.status == status && other.type == type;

  @override
  int get hashCode => Object.hash(status, type);

  @override
  String toString() => 'LessonAttendance(status: $status, type: $type)';
}
