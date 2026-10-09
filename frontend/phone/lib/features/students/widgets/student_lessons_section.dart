import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentLessonsSection extends ConsumerWidget {
  final String studentId;

  /// The student the section belongs to, shown by the lesson page.
  final String studentName;

  const new({super.key, required this.studentId, required this.studentName});

  static final List<LessonResponse> _dummyLessons = List.generate(6, (index) {
    final date = DateTime.now().add(Duration(days: index * 3));
    return LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
    );
  });

  static List<LessonResponse> _toLessons(
    List<VisitWithLessonResponse> visits,
  ) => visits
      .where(
        (v) =>
            v.visit.type == VisitType.regular || v.visit.type == VisitType.free,
      )
      .map((v) => v.lesson)
      .toList();

  /// The individual lesson of a day.
  ///
  /// A student is also marked present for the lessons of their group, so the
  /// lessons of a day contain group lessons as well. Those belong to the group
  /// and are edited from the group page: editing one here would replace the
  /// attendance of the whole group with the student that is shown on the page.
  @visibleForTesting
  static LessonResponse? individualLessonOf(List<LessonResponse> dayLessons) =>
      dayLessons.where((lesson) => lesson.groupId == null).firstOrNull;

  /// Opens the lesson of the tapped day, or an empty page when the day has no
  /// lesson yet.
  Future<void> _openLessonPage(
    BuildContext context,
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLessonPage(
          studentId: studentId,
          studentName: studentName,
          date: selectedDay,
          lesson: individualLessonOf(dayLessons),
        ),
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
        onDayTapped: (selectedDay, dayLessons) =>
            _openLessonPage(context, selectedDay, dayLessons),
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
