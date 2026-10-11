import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/calendar_month_navigator.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_lesson_calendar_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentLessonsSection extends ConsumerStatefulWidget {
  final String studentId;

  final String studentName;

  final GroupResponse? studentGroup;

  const new({
    super.key,
    required this.studentId,
    required this.studentName,
    this.studentGroup,
  });

  @override
  ConsumerState<StudentLessonsSection> createState() =>
      _StudentLessonsSectionState();

  static bool _isLessonVisit(VisitWithLessonResponse visit) =>
      visit.visit.type == VisitType.regular ||
      visit.visit.type == VisitType.free;

  static List<LessonResponse> _toLessons(
    List<VisitWithLessonResponse> visits,
  ) => visits.map((visit) => visit.lesson).toList();

  @visibleForTesting
  static List<VisitWithLessonResponse> lessonVisitsOf(
    List<VisitWithLessonResponse> visits,
  ) => visits.where(_isLessonVisit).toList();

  @visibleForTesting
  static List<VisitWithLessonResponse> individualVisits(
    List<VisitWithLessonResponse> visits,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == null)
          .toList();

  @visibleForTesting
  static List<VisitWithLessonResponse> groupVisits(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == groupId)
          .toList();

  @visibleForTesting
  static List<LessonResponse> individualLessons(
    List<VisitWithLessonResponse> visits,
  ) => _toLessons(individualVisits(visits));

  @visibleForTesting
  static List<LessonResponse> groupLessons(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) => _toLessons(groupVisits(visits, groupId));

  @visibleForTesting
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

  @visibleForTesting
  static List<VisitWithLessonResponse> dayVisitsOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => visits
      .where((visit) => DateUtils.isSameDay(visit.lesson.date, day))
      .toList();

  @visibleForTesting
  static List<VisitStatus> dayVisitStatusesOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => dayVisitsOf(
    visits,
    day,
  ).where(_isLessonVisit).map((visit) => visit.visit.status).toList();

  @visibleForTesting
  static List<StudentDayLesson> individualLessonsOf(
    List<VisitWithLessonResponse> dayVisits,
  ) => _studentDayLessons(dayVisits, (lesson) => lesson.groupId == null);

  @visibleForTesting
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

  @visibleForTesting
  static bool showsIndividualCalendar(
    List<VisitWithLessonResponse> visits,
    List<GroupResponse> groups,
  ) => individualVisits(visits).isNotEmpty || groups.isEmpty;

  @visibleForTesting
  static bool opensCreatePageDirectly(
    List<VisitWithLessonResponse> dayVisits,
  ) => dayVisits.isEmpty;

  static final List<VisitWithLessonResponse> _dummyVisits = List.generate(6, (
    index,
  ) {
    final date = DateTime.now().add(Duration(days: index * 3));
    final lesson = LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
      groupId: index.isOdd ? 'placeholder-group' : null,
    );

    return VisitWithLessonResponse(
      visit: VisitResponse(
        id: 'placeholder-visit-$index',
        status: VisitStatus.present,
        type: VisitType.regular,
        lessonId: lesson.id,
        studentId: 'placeholder-student',
        createdAt: date,
      ),
      lesson: lesson,
    );
  });
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
    await _openGroupLessonPage(group.id, DateTime.now(), null);
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
      await _openGroupLessonPage(group.id, selectedDay, null);
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

    await _openGroupLessonPage(group.id, selectedDay, selection.lesson);
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
    String groupId,
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            LessonPage(groupId: groupId, date: selectedDay, lesson: lesson),
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
          CalendarMonthNavigator(
            focusedDay: focusedDay,
            locale: locale,
            onPreviousMonth: _canGoBackwards(focusedDay)
                ? () => _showMonth(-1)
                : null,
            onNextMonth: _canGoForward(focusedDay) ? () => _showMonth(1) : null,
          ),
          _StudentLessonsBody(
            visitsAsync: visitsAsync,
            isLoadingEarlier: isLoadingEarlier,
            focusedDay: focusedDay,
            groups: groups,
            studentGroup: widget.studentGroup,
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

class _StudentLessonsBody extends StatelessWidget {
  final AsyncValue<List<VisitWithLessonResponse>> visitsAsync;
  final bool isLoadingEarlier;
  final DateTime focusedDay;
  final List<GroupSummaryResponse>? groups;
  final GroupResponse? studentGroup;
  final String? locale;
  final void Function(GroupResponse group, DateTime day, List<VisitWithLessonResponse> visits)
  onGroupDayTapped;
  final void Function(DateTime day, List<VisitWithLessonResponse> visits)
  onIndividualDayTapped;
  final ValueChanged<GroupResponse> onCreateGroupLesson;
  final VoidCallback onCreateIndividualLesson;

  const new({
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
      child: _LessonsCalendarColumn(
        visits: visits ?? StudentLessonsSection._dummyVisits,
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

class _LessonsCalendarColumn extends StatelessWidget {
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
    final studentGroups = _studentGroups(visits, groups, studentGroup);
    final individualVisits = StudentLessonsSection.individualVisits(visits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final group in studentGroups)
          _GroupLessonCalendar(
            key: ValueKey(group.id),
            group: group,
            visits: StudentLessonsSection.groupVisits(visits, group.id),
            focusedDay: focusedDay,
            locale: locale,
            onDayTapped: onGroupDayTapped,
            onCreate: () => onCreateGroupLesson(group),
          ),
        if (StudentLessonsSection.showsIndividualCalendar(visits, studentGroups))
          StudentLessonCalendarSection(
            title: context.t.lessons.individualLessons,
            locale: locale,
            lessons: StudentLessonsSection._toLessons(individualVisits),
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

class _GroupLessonCalendar extends StatelessWidget {
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

List<GroupResponse> _studentGroups(
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
