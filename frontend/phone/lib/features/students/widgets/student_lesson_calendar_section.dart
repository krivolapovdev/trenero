import 'package:flutter/material.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';

/// One block of the lessons of a student: the title of the block with the
/// action that creates a lesson of it, over the calendar that draws only its own
/// lessons.
///
/// The calendar is driven by the owner through [focusedDay] and is not stepped
/// by a sideways swipe, so the blocks of the section move through the months
/// together with the single header of the section only. The surface and the
/// header of the calendar are hidden, so the block sits inside the surface of
/// the section together with the other blocks.
class StudentLessonCalendarSection extends StatelessWidget {
  /// The title drawn at the left of the header of the block: `Individual
  /// lessons` or the name of a group.
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

  /// Called when the action of the header is tapped, it opens the page that
  /// creates a lesson of this block.
  ///
  /// The action sits at the right of the title, so the block of a group creates
  /// a lesson of that group while the block of the individual lessons creates an
  /// individual one. When no action is given the block draws the title and the
  /// calendar alone.
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
