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

  List<GroupResponse> _groups(
    List<VisitWithLessonResponse> visits,
    List<GroupSummaryResponse>? groups,
  ) {
    final orderedGroups = <GroupResponse>[];
    final seenGroupIds = <String>{};
    final studentGroup = widget.studentGroup;

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

  Widget _buildSections(
    BuildContext context,
    List<VisitWithLessonResponse> visits,
    DateTime focusedDay,
    List<GroupSummaryResponse>? groups,
    String? locale,
  ) {
    final studentGroups = _groups(visits, groups);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final group in studentGroups)
          _buildCalendarSection(
            context,
            title: group.name,
            visits: StudentLessonsSection.groupVisits(visits, group.id),
            focusedDay: focusedDay,
            locale: locale,
            group: group,
            onCreate: () => _createGroupLesson(context, group),
          ),
        if (StudentLessonsSection.showsIndividualCalendar(
          visits,
          studentGroups,
        ))
          _buildCalendarSection(
            context,
            title: context.t.lessons.individualLessons,
            visits: StudentLessonsSection.individualVisits(visits),
            focusedDay: focusedDay,
            locale: locale,
            onCreate: () => _createIndividualLesson(context),
          ),
      ],
    );
  }

  Widget _buildCalendarSection(
    BuildContext context, {
    required String title,
    required List<VisitWithLessonResponse> visits,
    required DateTime focusedDay,
    required String? locale,
    GroupResponse? group,
    VoidCallback? onCreate,
  }) => StudentLessonCalendarSection(
    title: title,
    locale: locale,
    lessons: StudentLessonsSection._toLessons(visits),
    focusedDay: focusedDay,
    dayVisitStatuses: (day) =>
        StudentLessonsSection.dayVisitStatusesOf(visits, day),
    onCreate: onCreate,
    onDayTapped: (selectedDay, dayLessons) => group == null
        ? _openIndividualDay(context, selectedDay, visits)
        : _openGroupDay(context, selectedDay, group, visits),
  );

  Future<void> _createGroupLesson(
    BuildContext context,
    GroupResponse group,
  ) async {
    await _openGroupLessonPage(context, group.id, DateTime.now(), null);
  }

  Future<void> _createIndividualLesson(BuildContext context) async {
    await _openIndividualLessonPage(context, DateTime.now(), null);
  }

  Future<void> _openIndividualDay(
    BuildContext context,
    DateTime selectedDay,
    List<VisitWithLessonResponse> visits,
  ) async {
    final dayVisits = StudentLessonsSection.dayVisitsOf(visits, selectedDay);

    if (StudentLessonsSection.opensCreatePageDirectly(dayVisits)) {
      await _openIndividualLessonPage(context, selectedDay, null);
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

    await _openIndividualLessonPage(context, selectedDay, selection.lesson);
  }

  Future<void> _openGroupDay(
    BuildContext context,
    DateTime selectedDay,
    GroupResponse group,
    List<VisitWithLessonResponse> visits,
  ) async {
    final dayVisits = StudentLessonsSection.dayVisitsOf(visits, selectedDay);

    if (StudentLessonsSection.opensCreatePageDirectly(dayVisits)) {
      await _openGroupLessonPage(context, group.id, selectedDay, null);
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

    await _openGroupLessonPage(
      context,
      group.id,
      selectedDay,
      selection.lesson,
    );
  }

  Future<void> _openIndividualLessonPage(
    BuildContext context,
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
    BuildContext context,
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

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<VisitWithLessonResponse>> visitsAsync,
    bool isLoadingEarlier,
    DateTime focusedDay,
    List<GroupSummaryResponse>? groups,
    String? locale,
  ) {
    if (visitsAsync.hasError && !visitsAsync.hasValue) {
      return Center(
        child: Text(context.t.lessons.errorLoading(error: visitsAsync.error!)),
      );
    }

    return Skeletonizer(
      enabled: visitsAsync.isLoading || isLoadingEarlier,
      child: _buildSections(
        context,
        visitsAsync.value ?? StudentLessonsSection._dummyVisits,
        focusedDay,
        groups,
        locale,
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
          _buildBody(
            context,
            visitsAsync,
            isLoadingEarlier,
            focusedDay,
            groups,
            locale,
          ),
        ],
      ),
    );
  }
}
