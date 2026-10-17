import 'package:flutter/material.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';

const Color _lightGreenAlpha = Color(0x4D4CAF50);
const Color _darkForestGreen = Color(0xFF1B5E20);

const Color _lightBlueAlpha = Color(0x4D2196F3);
const Color _darkBlue = Color(0xFF0D47A1);

const Color _lightRedAlpha = Color(0x4DF44336);
const Color _darkRed = Color(0xFFB71C1C);

({Color background, Color foreground}) dayColors(
  List<VisitStatus>? statuses,
  List<LessonResponse> dayLessons,
) {
  final hasStatuses = statuses != null && statuses.isNotEmpty;
  final isAttended =
      hasStatuses && statuses.every((status) => status == VisitStatus.present);
  final isMissed =
      hasStatuses && statuses.every((status) => status == VisitStatus.absent);

  if (isAttended) {
    return (background: _lightGreenAlpha, foreground: _darkForestGreen);
  }

  if (isMissed) {
    return (background: _lightRedAlpha, foreground: _darkRed);
  }

  final hasIndividualLesson = dayLessons.any(
    (lesson) => lesson.groupId == null,
  );

  return hasIndividualLesson
      ? (background: _lightBlueAlpha, foreground: _darkBlue)
      : (background: _lightGreenAlpha, foreground: _darkForestGreen);
}
