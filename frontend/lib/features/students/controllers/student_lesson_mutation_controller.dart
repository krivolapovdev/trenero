import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/student_visit.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';

final studentLessonMutationControllerProvider =
    AsyncNotifierProvider<StudentLessonMutationController, void>(
      StudentLessonMutationController.new,
    );

/// Creates, updates and deletes the individual lessons of a student.
///
/// An individual lesson is a lesson without a group that holds exactly one
/// student, so it is sent with a `null` groupId and the single visit of the
/// student. Every mutation reloads the lessons of the student, so the calendar
/// of the student page is up to date when the lesson page closes.
class StudentLessonMutationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createStudentLesson({
    required String studentId,
    required DateTime date,
    required bool isPresent,
  }) => _mutate(
    studentId,
    () => ref
        .read(lessonServiceProvider)
        .createLesson(
          body: CreateLessonRequest(
            date: _asDay(date),
            students: [_buildVisit(studentId, isPresent)],
          ),
        ),
  );

  Future<bool> updateStudentLesson({
    required String lessonId,
    required String studentId,
    required DateTime date,
    required bool isPresent,
  }) => _mutate(studentId, () async {
    await ref
        .read(lessonServiceProvider)
        .updateLesson(
          lessonId: lessonId,
          body: UpdateLessonRequest(
            date: _asDay(date),
            students: [_buildVisit(studentId, isPresent)],
          ),
        );

    // The attendance shown by the lesson page is loaded from the server and
    // has to be dropped once it changed.
    ref.invalidate(lessonDetailsProvider(lessonId));
  });

  Future<bool> deleteStudentLesson({
    required String lessonId,
    required String studentId,
  }) => _mutate(
    studentId,
    () => ref.read(lessonServiceProvider).deleteLesson(lessonId: lessonId),
  );

  Future<bool> _mutate(String studentId, Future<void> Function() action) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await action();

      await ref.read(studentLessonsProvider(studentId).notifier).refresh();

      // The lesson changes the attendance of the student, so the statuses of
      // the student list have to be reloaded as well.
      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);
    });

    return !state.hasError;
  }

  /// A student that attended is marked present and regular, a student that did
  /// not is marked absent and regular.
  StudentVisit _buildVisit(String studentId, bool isPresent) => isPresent
      ? StudentVisit(
          studentId: studentId,
          status: VisitStatus.present,
          type: VisitType.regular,
        )
      : StudentVisit(
          studentId: studentId,
          status: VisitStatus.absent,
          type: VisitType.regular,
        );

  /// The backend stores lessons per day, so the time part is dropped.
  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
