import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/widgets/student_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentLessonsSection extends ConsumerWidget {
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

  static final List<LessonResponse> _dummyLessons = List.generate(6, (index) {
    final date = DateTime.now().add(Duration(days: index * 3));
    return LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
    );
  });

  /// Whether the calendar draws the lesson of [visit].
  ///
  /// Only a regular or a free visit records a lesson, the other kinds are not
  /// shown on the calendar.
  static bool _isLessonVisit(VisitWithLessonResponse visit) =>
      visit.visit.type == VisitType.regular ||
      visit.visit.type == VisitType.free;

  static List<LessonResponse> _toLessons(
    List<VisitWithLessonResponse> visits,
  ) => visits.where(_isLessonVisit).map((visit) => visit.lesson).toList();

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

  /// Whether tapping a day opens the page that creates an individual lesson
  /// straight away instead of the day sheet.
  ///
  /// Without a group there is no group lesson to offer, so a day without a
  /// stored lesson leaves the sheet with the single create row that leads to
  /// the same page.
  @visibleForTesting
  static bool opensCreatePageDirectly(
    GroupResponse? studentGroup,
    List<VisitWithLessonResponse> dayVisits,
  ) => studentGroup == null && dayVisits.isEmpty;

  /// Shows the lessons of the tapped day and opens the lesson the user picks.
  ///
  /// The day sheet is skipped when there is nothing to pick from, the page that
  /// creates an individual lesson is opened by default then.
  Future<void> _openDayLessons(
    BuildContext context,
    DateTime selectedDay,
    List<VisitWithLessonResponse> visits,
  ) async {
    final dayVisits = dayVisitsOf(visits, selectedDay);

    if (opensCreatePageDirectly(studentGroup, dayVisits)) {
      await _openIndividualLessonPage(context, selectedDay, null);
      return;
    }

    final selection = await AppBottomSheet.show<StudentDayLessonSelection>(
      context: context,
      child: StudentDayLessonsBottomSheet(
        studentName: studentName,
        individualLessons: individualLessonsOf(dayVisits),
        groupLessons: groupLessonsOf(dayVisits),
        studentGroup: studentGroup,
      ),
    );

    if (selection == null || !context.mounted) return;

    if (selection.action == StudentDayLessonAction.individual) {
      await _openIndividualLessonPage(context, selectedDay, selection.lesson);
      return;
    }

    final groupId = studentGroup?.id;
    if (groupId == null) return;

    await _openGroupLessonPage(context, groupId, selectedDay, selection.lesson);
  }

  Future<void> _openIndividualLessonPage(
    BuildContext context,
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLessonPage(
          studentId: studentId,
          studentName: studentName,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(studentLessonsProvider(studentId));
    final localeAsync = ref.watch(languageProvider);

    return visitsAsync.when(
      data: (visitsWithLessons) => LessonsCalendar(
        lessons: _toLessons(visitsWithLessons),
        locale: localeAsync.value?.languageTag,
        dayVisitStatuses: (day) => dayVisitStatusesOf(visitsWithLessons, day),
        onDayTapped: (selectedDay, _) =>
            _openDayLessons(context, selectedDay, visitsWithLessons),
      ),
      loading: () {
        final previousVisits = visitsAsync.value;

        return Skeletonizer(
          child: LessonsCalendar(
            lessons: previousVisits == null
                ? _dummyLessons
                : _toLessons(previousVisits),
            locale: localeAsync.value?.languageTag,
          ),
        );
      },
      error: (error, stack) =>
          Center(child: Text('Error loading lessons: $error')),
    );
  }
}
