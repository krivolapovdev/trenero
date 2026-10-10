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

/// The calendar of the lessons of a student, split by the kind of lesson.
///
/// The section draws a single surface that holds the shared month header and,
/// under it, one calendar for the individual lessons followed by one calendar
/// per group the student has lessons in. Every calendar shows the same month
/// and only its own lessons, so the lessons of the student can be told apart at
/// a glance.
class StudentLessonsSection extends ConsumerStatefulWidget {
  final String studentId;

  /// The student the section belongs to, shown by the lesson page.
  final String studentName;

  /// The group of the student, used to create and list their group lessons.
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

  /// Whether the calendar draws the lesson of [visit].
  ///
  /// Only a regular or a free visit records a lesson, the other kinds are not
  /// shown on the calendars.
  static bool _isLessonVisit(VisitWithLessonResponse visit) =>
      visit.visit.type == VisitType.regular ||
      visit.visit.type == VisitType.free;

  static List<LessonResponse> _toLessons(
    List<VisitWithLessonResponse> visits,
  ) => visits.map((visit) => visit.lesson).toList();

  /// The visits of [visits] that record a lesson.
  @visibleForTesting
  static List<VisitWithLessonResponse> lessonVisitsOf(
    List<VisitWithLessonResponse> visits,
  ) => visits.where(_isLessonVisit).toList();

  /// The visits of [visits] that record an individual lesson.
  @visibleForTesting
  static List<VisitWithLessonResponse> individualVisits(
    List<VisitWithLessonResponse> visits,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == null)
          .toList();

  /// The visits of [visits] that record a lesson of the group [groupId].
  @visibleForTesting
  static List<VisitWithLessonResponse> groupVisits(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) =>
      lessonVisitsOf(visits)
          .where((visit) => visit.lesson.groupId == groupId)
          .toList();

  /// The individual lessons of the student.
  @visibleForTesting
  static List<LessonResponse> individualLessons(
    List<VisitWithLessonResponse> visits,
  ) => _toLessons(individualVisits(visits));

  /// The lessons of the student that belong to the group [groupId].
  @visibleForTesting
  static List<LessonResponse> groupLessons(
    List<VisitWithLessonResponse> visits,
    String groupId,
  ) => _toLessons(groupVisits(visits, groupId));

  /// The groups the student has lessons in, the group of the oldest lesson
  /// first.
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

  /// The visits that take place on [day].
  @visibleForTesting
  static List<VisitWithLessonResponse> dayVisitsOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => visits
      .where((visit) => DateUtils.isSameDay(visit.lesson.date, day))
      .toList();

  /// The statuses of the visits the calendar draws on [day], used to colour the
  /// day by the attendance of the student.
  @visibleForTesting
  static List<VisitStatus> dayVisitStatusesOf(
    List<VisitWithLessonResponse> visits,
    DateTime day,
  ) => dayVisitsOf(
    visits,
    day,
  ).where(_isLessonVisit).map((visit) => visit.visit.status).toList();

  /// The individual lessons of a day with the attendance of the student.
  @visibleForTesting
  static List<StudentDayLesson> individualLessonsOf(
    List<VisitWithLessonResponse> dayVisits,
  ) => _studentDayLessons(dayVisits, (lesson) => lesson.groupId == null);

  /// The group lessons of a day with the attendance of the student.
  ///
  /// A group lesson is stored for every student of the group, so the visit of
  /// the student tells whether they were present or missed the lesson.
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

  /// Whether the section draws the calendar of the individual lessons.
  ///
  /// The individual calendar is dropped for a student whose lessons are all
  /// group lessons, the group calendars are the ones that tell their story. A
  /// student without a group keeps the individual calendar even when no lesson
  /// is stored for them yet, so there is still a calendar to start a lesson
  /// from.
  @visibleForTesting
  static bool showsIndividualCalendar(
    List<VisitWithLessonResponse> visits,
    List<GroupResponse> groups,
  ) => individualVisits(visits).isNotEmpty || groups.isEmpty;

  /// Whether tapping a day of a calendar opens the page that creates a lesson
  /// straight away instead of the day sheet.
  ///
  /// A day without a lesson of the kind the calendar draws leaves nothing to
  /// pick from, so the page that creates a lesson of that kind is opened
  /// directly.
  @visibleForTesting
  static bool opensCreatePageDirectly(
    List<VisitWithLessonResponse> dayVisits,
  ) => dayVisits.isEmpty;

  /// Placeholder visits drawn while the lessons are loading.
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
        status: VisitStatus.unmarked,
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
  /// The month every calendar of the section shows.
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateUtils.dateOnly(DateTime.now());
  }

  /// The first month the section can step back to.
  static final DateTime _firstMonth = DateTime(2000, 1);

  /// Whether the section may show [month].
  ///
  /// Lessons are only ever recorded for the past, so the months after the
  /// current one cannot be shown.
  bool _canShow(DateTime month) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return !month.isBefore(_firstMonth) && !month.isAfter(currentMonth);
  }

  /// Whether the header may step a month forward from the shown month.
  bool get _canGoForward =>
      _canShow(DateTime(_focusedDay.year, _focusedDay.month + 1));

  /// Whether the header may step a month back from the shown month.
  bool get _canGoBackwards =>
      _canShow(DateTime(_focusedDay.year, _focusedDay.month - 1));

  /// Steps the shown month by [months], the shared header drives every calendar
  /// of the section with it.
  ///
  /// Stepping back loads the months before the loaded range from the server
  /// when they are not stored locally yet.
  void _showMonth(int months) {
    final month = DateTime(_focusedDay.year, _focusedDay.month + months);
    if (!_canShow(month)) return;

    setState(() {
      _focusedDay = month;
    });

    if (months < 0) {
      ref
          .read(studentLessonsProvider(widget.studentId).notifier)
          .loadEarlierMonths(month);
    }
  }

  /// The groups the section draws a calendar for: the group the student belongs
  /// to first, then every other group the student has lessons in.
  List<GroupResponse> _groups(
    List<VisitWithLessonResponse> visits,
    List<GroupSummaryResponse>? groups,
  ) {
    final result = <GroupResponse>[];
    final seen = <String>{};
    final studentGroup = widget.studentGroup;

    if (studentGroup != null) {
      result.add(studentGroup);
      seen.add(studentGroup.id);
    }

    for (final groupId in StudentLessonsSection.groupIdsOf(visits)) {
      if (seen.add(groupId)) result.add(_groupOf(groupId, groups));
    }

    return result;
  }

  /// The group [groupId] as the lesson page needs it, named through the groups
  /// of the trainer.
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

  /// The calendars of the section: one per group first, the individual lessons
  /// last.
  ///
  /// The section leans on the group of the student when there is no lesson to
  /// tell the calendars apart: a student with a group keeps the group calendars
  /// alone, a student without a group keeps the individual calendar alone.
  Widget _buildSections(
    BuildContext context,
    List<VisitWithLessonResponse> visits,
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
            locale: locale,
            group: group,
          ),
        if (StudentLessonsSection.showsIndividualCalendar(
          visits,
          studentGroups,
        ))
          _buildCalendarSection(
            context,
            title: context.t.lessons.individualLessons,
            visits: StudentLessonsSection.individualVisits(visits),
            locale: locale,
          ),
      ],
    );
  }

  Widget _buildCalendarSection(
    BuildContext context, {
    required String title,
    required List<VisitWithLessonResponse> visits,
    required String? locale,
    GroupResponse? group,
  }) => StudentLessonCalendarSection(
    title: title,
    locale: locale,
    lessons: StudentLessonsSection._toLessons(visits),
    focusedDay: _focusedDay,
    dayVisitStatuses: (day) =>
        StudentLessonsSection.dayVisitStatusesOf(visits, day),
    onDayTapped: (selectedDay, dayLessons) => group == null
        ? _openIndividualDay(context, selectedDay, visits)
        : _openGroupDay(context, selectedDay, group, visits),
  );

  /// Opens the individual lesson of the tapped day, or the page that creates
  /// one when the day has none.
  ///
  /// The day sheet holds the individual lessons alone: the calendar of the
  /// individual lessons never offers a group lesson next to them.
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

  /// Opens the lesson of [group] on the tapped day, or the page that creates one
  /// when the day has none.
  ///
  /// The day sheet holds the lessons of [group] alone: the calendar of a group
  /// never offers an individual lesson next to them.
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

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(studentLessonsProvider(widget.studentId));
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
            focusedDay: _focusedDay,
            locale: locale,
            onPreviousMonth: _canGoBackwards ? () => _showMonth(-1) : null,
            onNextMonth: _canGoForward ? () => _showMonth(1) : null,
          ),
          visitsAsync.when(
            data: (visits) => _buildSections(context, visits, groups, locale),
            loading: () => Skeletonizer(
              child: _buildSections(
                context,
                visitsAsync.value ?? StudentLessonsSection._dummyVisits,
                groups,
                locale,
              ),
            ),
            error: (error, stack) =>
                Center(child: Text('Error loading lessons: $error')),
          ),
        ],
      ),
    );
  }
}
