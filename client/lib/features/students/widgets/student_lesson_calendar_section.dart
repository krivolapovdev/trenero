import 'package:flutter/material.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';

class StudentLessonCalendarSection extends StatelessWidget {
  final String title;

  final List<LessonResponse> lessons;

  final String? locale;

  final DateTime focusedDay;

  final void Function(DateTime selectedDay, List<LessonResponse> dayLessons)
  onDayTapped;

  final List<VisitStatus> Function(DateTime day)? dayVisitStatuses;

  final VoidCallback? onCreate;

  const new({
    super.key,
    required this.title,
    required this.lessons,
    required this.focusedDay,
    required this.onDayTapped,
    this.locale,
    this.dayVisitStatuses,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 18),
            ),
            if (onCreate != null) CreateLessonButton(onPressed: onCreate),
          ],
        ),
      ),
      LessonsCalendar(
        lessons: lessons,
        locale: locale,
        focusedDay: focusedDay,
        dayVisitStatuses: dayVisitStatuses,
        onDayTapped: onDayTapped,
        headerVisible: false,
        surfaceVisible: false,
        swipeEnabled: false,
      ),
    ],
  );
}
