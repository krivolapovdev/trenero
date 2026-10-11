import 'package:flutter/material.dart';
import 'package:phone/features/students/widgets/group_lesson_calendar.dart';
import 'package:phone/features/students/widgets/student_lesson_calendar_section.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

List<GroupResponse> studentGroups(
  List<VisitWithLessonResponse> visits,
  List<GroupSummaryResponse>? groups,
  GroupResponse? studentGroup,
) {
  final orderedGroups = <GroupResponse>[];
  final seenGroupIds = <String>{};

  if (studentGroup != null) {
    orderedGroups.add(studentGroup);
    seenGroupIds.add(studentGroup.id);
  }

  for (final groupId in StudentLessonsSection.groupIdsOf(visits)) {
    if (seenGroupIds.add(groupId)) {
      orderedGroups.add(_groupOf(groupId, groups));
    }
  }

  return orderedGroups;
}

GroupResponse _groupOf(String groupId, List<GroupSummaryResponse>? groups) {
  for (final group in groups ?? const <GroupSummaryResponse>[]) {
    if (group.id == groupId) {
      return GroupResponse(
        id: group.id,
        name: group.name,
        createdAt: group.createdAt,
        defaultPrice: group.defaultPrice,
        note: group.note,
      );
    }
  }

  return GroupResponse(id: groupId, name: groupId, createdAt: DateTime.now());
}

class LessonsCalendarColumn extends StatelessWidget {
  final List<VisitWithLessonResponse> visits;
  final List<GroupSummaryResponse>? groups;
  final GroupResponse? studentGroup;
  final DateTime focusedDay;
  final String? locale;
  final void Function(GroupResponse group, DateTime day, List<VisitWithLessonResponse> visits)
  onGroupDayTapped;
  final void Function(DateTime day, List<VisitWithLessonResponse> visits)
  onIndividualDayTapped;
  final ValueChanged<GroupResponse> onCreateGroupLesson;
  final VoidCallback onCreateIndividualLesson;

  const new({
    super.key,
    required this.visits,
    required this.focusedDay,
    required this.onGroupDayTapped,
    required this.onIndividualDayTapped,
    required this.onCreateGroupLesson,
    required this.onCreateIndividualLesson,
    this.groups,
    this.studentGroup,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final studentGroupsList = studentGroups(visits, groups, studentGroup);
    final individualVisits = StudentLessonsSection.individualVisits(visits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final group in studentGroupsList)
          GroupLessonCalendar(
            key: ValueKey(group.id),
            group: group,
            visits: StudentLessonsSection.groupVisits(visits, group.id),
            focusedDay: focusedDay,
            locale: locale,
            onDayTapped: onGroupDayTapped,
            onCreate: () => onCreateGroupLesson(group),
          ),
        if (StudentLessonsSection.showsIndividualCalendar(visits, studentGroupsList))
          StudentLessonCalendarSection(
            title: context.t.lessons.individualLessons,
            locale: locale,
            lessons: StudentLessonsSection.toLessons(individualVisits),
            focusedDay: focusedDay,
            dayVisitStatuses: (day) =>
                StudentLessonsSection.dayVisitStatusesOf(individualVisits, day),
            onCreate: onCreateIndividualLesson,
            onDayTapped: (day, _) => onIndividualDayTapped(day, individualVisits),
          ),
      ],
    );
  }
}
