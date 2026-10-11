import 'package:flutter/foundation.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';

/// The mark a student carries on a lesson.
///
/// A student that is left unmarked has no [LessonAttendance] at all: the mark
/// is simply missing from the map the page keeps, so "unmarked" is never a
/// stored state and the visit of the student is deleted.
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
