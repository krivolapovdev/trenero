import 'package:flutter/material.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';

/// One block of the lessons of a student: the title over the calendar that
/// draws only its own lessons.
///
/// The calendar is driven by the owner through [focusedDay] and is not stepped
/// by a sideways swipe, so the blocks of the section move through the months
/// together with the single header of the section only. The surface and the
/// header of the calendar are hidden, so the block sits inside the surface of
/// the section together with the other blocks.
class StudentLessonCalendarSection extends StatelessWidget {
  /// The title drawn above the calendar, at the left: `Individual lessons` or
  /// the name of a group.
  final String title;

  /// The lessons the calendar draws.
  final List<LessonResponse> lessons;

  /// The locale the calendar is written in.
  final String? locale;

  /// The month the calendar shows, driven by the owner.
  final DateTime focusedDay;

  /// Called when a day is tapped, with the lessons that take place on it.
  final void Function(DateTime selectedDay, List<LessonResponse> dayLessons)
  onDayTapped;

  /// The statuses of the visits of this block that take place on a day, used to
  /// colour the day by the attendance of the student.
  final List<VisitStatus> Function(DateTime day)? dayVisitStatuses;

  const new({
    super.key,
    required this.title,
    required this.lessons,
    required this.focusedDay,
    required this.onDayTapped,
    this.locale,
    this.dayVisitStatuses,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
