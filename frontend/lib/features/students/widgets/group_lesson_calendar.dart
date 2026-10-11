import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/student_lesson_calendar_section.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';

class GroupLessonCalendar extends StatelessWidget {
  final GroupResponse group;
  final List<VisitWithLessonResponse> visits;
  final DateTime focusedDay;
  final String? locale;
  final void Function(GroupResponse group, DateTime day, List<VisitWithLessonResponse> visits)
  onDayTapped;
  final VoidCallback onCreate;

  const new({
    super.key,
    required this.group,
    required this.visits,
    required this.focusedDay,
    required this.onDayTapped,
    required this.onCreate,
    this.locale,
  });

  @override
  Widget build(BuildContext context) => StudentLessonCalendarSection(
    title: group.name,
    locale: locale,
    lessons: StudentLessonsSection.groupLessons(visits, group.id),
    focusedDay: focusedDay,
    dayVisitStatuses: (day) =>
        StudentLessonsSection.dayVisitStatusesOf(visits, day),
    onCreate: onCreate,
    onDayTapped: (day, _) => onDayTapped(group, day, visits),
  );
}
