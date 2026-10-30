import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
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
    LessonAttendance? attendance,
    bool? isPresent,
  }) => _mutate(
    studentId,
    () => ref
        .read(lessonServiceProvider)
        .createLesson(
          body: CreateLessonRequest(
            date: _asDay(date),
            students: _buildVisits(studentId, attendance, isPresent),
          ),
        ),
  );

  Future<bool> updateStudentLesson({
    required String lessonId,
    required String studentId,
    required DateTime date,
    LessonAttendance? attendance,
    bool? isPresent,
  }) => _mutate(studentId, () async {
    await ref
        .read(lessonServiceProvider)
        .updateLesson(
          lessonId: lessonId,
          body: UpdateLessonRequest(
            date: _asDay(date),
            students: _buildVisits(studentId, attendance, isPresent),
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

      ref
        ..invalidate(groupStudentsProvider)
        ..invalidate(groupReportProvider);

      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);
    });

    return !state.hasError;
  }

  List<StudentVisit> _buildVisits(
    String studentId,
    LessonAttendance? attendance,
    bool? isPresent,
  ) {
    if (attendance != null) {
      return [
        StudentVisit(
          studentId: studentId,
          status: attendance.status,
          type: attendance.type,
        ),
      ];
    }
    if (isPresent != null) {
      return [
        StudentVisit(
          studentId: studentId,
          status: isPresent ? VisitStatus.present : VisitStatus.absent,
          type: VisitType.regular,
        ),
      ];
    }
    return const [];
  }

  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
