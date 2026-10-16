import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/calendar_month_header.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_lessons_body.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';

class StudentLessonsSection extends ConsumerStatefulWidget {
  final String studentId;

  final String studentName;

  final List<GroupResponse> studentGroups;

  const new({
    super.key,
    required this.studentId,
    required this.studentName,
    this.studentGroups = const [],
  });

  @override
  ConsumerState<StudentLessonsSection> createState() =>
      _StudentLessonsSectionState();

  static bool isLessonVisit(VisitWithLessonResponse visit) =>
      visit.visit.type == VisitType.regular ||
      visit.visit.type == VisitType.free;

  static List<LessonResponse> toLessons(List<VisitWithLessonResponse> visits) =>
      visits.map((visit) => visit.lesson).toList();

  static List<VisitWithLessonResponse> lessonVisitsOf(
    List<VisitWithLessonResponse> visits,
  ) => visits.where(isLessonVisit).toList();

  static List<VisitWithLessonResponse> individualVisits(
    List<VisitWithLessonResponse> visits,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == null)
          .toList();

  static List<VisitWithLessonResponse> groupVisits(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == groupId)
          .toList();

  static List<LessonResponse> individualLessons(
    List<VisitWithLessonResponse> visits,
  ) => toLessons(individualVisits(visits));

  static List<LessonResponse> groupLessons(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) => toLessons(groupVisits(visits, groupId));

  static List<String> groupIdsOf(List<VisitWithLessonResponse> visits) {
    final groupIds = <String>[];

    for (final visit in lessonVisitsOf(visits)) {
      final groupId = visit.lesson.groupId;
      if (groupId != null && !groupIds.contains(groupId)) {
        groupIds.add(groupId);
      }
    }

    return groupIds;
  }

  static List<VisitWithLessonResponse> dayVisitsOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => visits
      .where((visit) => DateUtils.isSameDay(visit.lesson.date, day))
      .toList();

  static List<VisitStatus> dayVisitStatusesOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => dayVisitsOf(
    visits,
    day,
  ).where(isLessonVisit).map((visit) => visit.visit.status).toList();

  static List<StudentDayLesson> individualLessonsOf(
    List<VisitWithLessonResponse> dayVisits,
  ) => _studentDayLessons(dayVisits, (lesson) => lesson.groupId == null);

  static List<StudentDayLesson> groupLessonsOf(
    List<VisitWithLessonResponse> dayVisits,
  ) => _studentDayLessons(dayVisits, (lesson) => lesson.groupId != null);

  static List<StudentDayLesson> _studentDayLessons(
    List<VisitWithLessonResponse> dayVisits,
    bool Function(LessonResponse lesson) belongsToKind,
  ) => dayVisits
      .where((visit) => belongsToKind(visit.lesson))
      .map(
        (visit) => StudentDayLesson(
          lesson: visit.lesson,
          visitStatus: visit.visit.status,
        ),
      )
      .toList();

  static bool showsIndividualCalendar(
    List<VisitWithLessonResponse> visits,
    List<GroupResponse> groups,
  ) => individualVisits(visits).isNotEmpty || groups.isEmpty;

  static bool opensCreatePageDirectly(
    List<VisitWithLessonResponse> dayVisits,
  ) => dayVisits.isEmpty;
}

class _StudentLessonsSectionState extends ConsumerState<StudentLessonsSection> {
  static final DateTime _firstMonth = DateTime(2000);

  bool _canShow(DateTime month) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return !month.isBefore(_firstMonth) && !month.isAfter(currentMonth);
  }

  bool _canGoForward(DateTime focusedDay) =>
      _canShow(DateTime(focusedDay.year, focusedDay.month + 1));

  bool _canGoBackwards(DateTime focusedDay) =>
      _canShow(DateTime(focusedDay.year, focusedDay.month - 1));

  void _showMonth(int months) {
    final focusedDay = ref.read(studentLessonsMonthProvider(widget.studentId));
    final month = DateTime(focusedDay.year, focusedDay.month + months);
    if (!_canShow(month)) return;

    ref
        .read(studentLessonsMonthProvider(widget.studentId).notifier)
        .show(month);

    if (months < 0) {
      ref
          .read(studentLessonsProvider(widget.studentId).notifier)
          .loadEarlierMonths(month);
    }
  }

  Future<void> _createGroupLesson(GroupResponse group) async {
    await _openGroupLessonPage(group, DateTime.now(), null);
  }

  Future<void> _createIndividualLesson() async {
    await _openIndividualLessonPage(DateTime.now(), null);
  }

  Future<void> _openIndividualDay(
    DateTime selectedDay,
    List<VisitWithLessonResponse> visits,
  ) async {
    final dayVisits = StudentLessonsSection.dayVisitsOf(visits, selectedDay);

    if (StudentLessonsSection.opensCreatePageDirectly(dayVisits)) {
      await _openIndividualLessonPage(selectedDay, null);
      return;
    }

    final selection = await AppBottomSheet.show<StudentDayLessonSelection>(
      context: context,
      child: StudentDayLessonsBottomSheet(
        studentName: widget.studentName,
        individualLessons: StudentLessonsSection.individualLessonsOf(dayVisits),
      ),
    );

    if (selection == null || !context.mounted) return;

    await _openIndividualLessonPage(selectedDay, selection.lesson);
  }

  Future<void> _openGroupDay(
    GroupResponse group,
    DateTime selectedDay,
    List<VisitWithLessonResponse> visits,
  ) async {
    final dayVisits = StudentLessonsSection.dayVisitsOf(visits, selectedDay);

    if (StudentLessonsSection.opensCreatePageDirectly(dayVisits)) {
      await _openGroupLessonPage(group, selectedDay, null);
      return;
    }

    final selection = await AppBottomSheet.show<StudentDayLessonSelection>(
      context: context,
      child: StudentDayLessonsBottomSheet(
        studentName: widget.studentName,
        groupLessons: StudentLessonsSection.groupLessonsOf(dayVisits),
        studentGroup: group,
        showIndividualSection: false,
      ),
    );

    if (selection == null || !context.mounted) return;

    await _openGroupLessonPage(group, selectedDay, selection.lesson);
  }

  Future<void> _openIndividualLessonPage(
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLessonPage(
          studentId: widget.studentId,
          studentName: widget.studentName,
          date: selectedDay,
          lesson: lesson,
        ),
      ),
    );
  }

  Future<void> _openGroupLessonPage(
    GroupResponse group,
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPage(
          groupId: group.id,
          groupName: group.name,
          date: selectedDay,
          lesson: lesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(studentLessonsProvider(widget.studentId));
    final isLoadingEarlier = ref.watch(
      studentLessonsLoadingEarlierProvider(widget.studentId),
    );
    final focusedDay = ref.watch(studentLessonsMonthProvider(widget.studentId));
    final groups = ref.watch(groupListControllerProvider).value;
    final locale = ref.watch(languageProvider).value?.languageTag;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CalendarMonthHeader(
              focusedDay: focusedDay,
              locale: locale,
              onPreviousMonth: _canGoBackwards(focusedDay)
                  ? () => _showMonth(-1)
                  : null,
              onNextMonth: _canGoForward(focusedDay)
                  ? () => _showMonth(1)
                  : null,
            ),
          ),
          StudentLessonsBody(
            visitsAsync: visitsAsync,
            isLoadingEarlier: isLoadingEarlier,
            focusedDay: focusedDay,
            groups: groups,
            studentGroups: widget.studentGroups,
            locale: locale,
            onGroupDayTapped: _openGroupDay,
            onIndividualDayTapped: _openIndividualDay,
            onCreateGroupLesson: _createGroupLesson,
            onCreateIndividualLesson: _createIndividualLesson,
          ),
        ],
      ),
    );
  }
}
