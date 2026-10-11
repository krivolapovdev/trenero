import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/widgets/lessons_calendar_column.dart';
import 'package:phone/features/students/widgets/student_lessons_dummy_visits.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentLessonsBody extends StatelessWidget {
  final AsyncValue<List<VisitWithLessonResponse>> visitsAsync;
  final bool isLoadingEarlier;
  final DateTime focusedDay;
  final List<GroupSummaryResponse>? groups;
  final GroupResponse? studentGroup;
  final String? locale;
  final void Function(
    GroupResponse group,
    DateTime day,
    List<VisitWithLessonResponse> visits,
  )
  onGroupDayTapped;
  final void Function(DateTime day, List<VisitWithLessonResponse> visits)
  onIndividualDayTapped;
  final ValueChanged<GroupResponse> onCreateGroupLesson;
  final VoidCallback onCreateIndividualLesson;

  const new({
    super.key,
    required this.visitsAsync,
    required this.isLoadingEarlier,
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
    final visits = visitsAsync.value;

    if (visitsAsync.hasError && visits == null) {
      return Center(
        child: Text(context.t.lessons.errorLoading(error: visitsAsync.error!)),
      );
    }

    return Skeletonizer(
      enabled: visitsAsync.isLoading || isLoadingEarlier,
      child: LessonsCalendarColumn(
        visits: visits ?? studentLessonsDummyVisits,
        groups: groups,
        studentGroup: studentGroup,
        focusedDay: focusedDay,
        locale: locale,
        onGroupDayTapped: onGroupDayTapped,
        onIndividualDayTapped: onIndividualDayTapped,
        onCreateGroupLesson: onCreateGroupLesson,
        onCreateIndividualLesson: onCreateIndividualLesson,
      ),
    );
  }
}
