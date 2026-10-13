import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
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
      await guardApiCall(action);

      await ref.read(studentLessonsProvider(studentId).notifier).refresh();

      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);
    });

    return !state.hasError;
  }

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

  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
