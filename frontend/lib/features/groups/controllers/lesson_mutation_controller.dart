import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Creates, updates and deletes the lessons of a group.
///
/// Every mutation reloads the lessons of the group, so the calendar of the
/// group page is up to date when the lesson page closes.
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

    // The attendance shown by the lesson page is loaded from the server and
    // has to be dropped once it changed.
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
      await action();

      await ref.read(groupLessonsProvider(groupId).notifier).refresh();

      // The attendance of the lesson changed the statuses the student list
      // shows, the monthly report of the group and the lessons the pages of the
      // students of the group draw.
      refreshAfterGroupLessonsMutation(
        ref,
        groupId: groupId,
        studentIds: studentIds,
      );
    });

    return !state.hasError;
  }

  /// The ids of the students of [groupId], used to refresh their pages after a
  /// lesson of the group changed.
  ///
  /// The group page caches the students of its group, so they are already loaded
  /// when a lesson is saved; a group whose students are not loaded yet has no
  /// page to refresh.
  Iterable<String> _groupStudentIds(String groupId) =>
      ref
          .read(groupStudentsProvider(groupId))
          .value
          ?.map((student) => student.id) ??
      const <String>[];

  /// The visits that are stored for the lesson.
  ///
  /// Only the students that carry a mark are sent: a student that is left
  /// unmarked is missing from [attendance] and loses their visit. A student
  /// who studies for free always stores a free lesson.
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

  /// The backend stores lessons per day, so the time part is dropped.
  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
