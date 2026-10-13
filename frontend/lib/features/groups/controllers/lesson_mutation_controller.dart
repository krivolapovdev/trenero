import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/student_visit.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_type.dart';

final lessonMutationControllerProvider =
    AsyncNotifierProvider<LessonMutationController, void>(
      LessonMutationController.new,
    );

class LessonMutationController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createLesson({
    required String groupId,
    required DateTime date,
    required List<GroupStudentSummaryResponse> students,
    required Map<String, LessonAttendance> attendance,
  }) => _mutate(
    groupId,
    () => ref
        .read(lessonServiceProvider)
        .createLesson(
          body: CreateLessonRequest(
            groupId: groupId,
            date: _asDay(date),
            students: _buildVisits(students, attendance),
          ),
        ),
    studentIds: students.map((student) => student.id),
  );

  Future<bool> updateLesson({
    required String lessonId,
    required String groupId,
    required DateTime date,
    required List<GroupStudentSummaryResponse> students,
    required Map<String, LessonAttendance> attendance,
  }) => _mutate(groupId, () async {
    await ref
        .read(lessonServiceProvider)
        .updateLesson(
          lessonId: lessonId,
          body: UpdateLessonRequest(
            date: _asDay(date),
            students: _buildVisits(students, attendance),
          ),
        );

    ref.invalidate(lessonDetailsProvider(lessonId));
  }, studentIds: students.map((student) => student.id));

  Future<bool> deleteLesson({
    required String lessonId,
    required String groupId,
  }) => _mutate(
    groupId,
    () => ref.read(lessonServiceProvider).deleteLesson(lessonId: lessonId),
    studentIds: _groupStudentIds(groupId),
  );

  Future<bool> _mutate(
    String groupId,
    Future<void> Function() action, {
    Iterable<String> studentIds = const <String>[],
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await guardApiCall(action);

      await ref.read(groupLessonsProvider(groupId).notifier).refresh();

      refreshAfterGroupLessonsMutation(
        ref,
        groupId: groupId,
        studentIds: studentIds,
      );
    });

    return !state.hasError;
  }

  Iterable<String> _groupStudentIds(String groupId) =>
      ref
          .read(groupStudentsProvider(groupId))
          .value
          ?.map((student) => student.id) ??
      const <String>[];

  List<StudentVisit> _buildVisits(
    List<GroupStudentSummaryResponse> students,
    Map<String, LessonAttendance> attendance,
  ) => students
      .where((student) => attendance.containsKey(student.id))
      .map(
        (student) => StudentVisit(
          studentId: student.id,
          status: attendance[student.id]!.status,
          type: student.free ? VisitType.free : attendance[student.id]!.type,
        ),
      )
      .toList();

  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
