import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/student_visit.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_status.dart';
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
    required Set<String> presentStudentIds,
  }) => _mutate(
    groupId,
    () => ref
        .read(lessonServiceProvider)
        .createLesson(
          body: CreateLessonRequest(
            groupId: groupId,
            date: _asDay(date),
            students: _buildVisits(students, presentStudentIds),
          ),
        ),
  );

  Future<bool> updateLesson({
    required String lessonId,
    required String groupId,
    required DateTime date,
    required List<GroupStudentSummaryResponse> students,
    required Set<String> presentStudentIds,
  }) => _mutate(groupId, () async {
    await ref
        .read(lessonServiceProvider)
        .updateLesson(
          lessonId: lessonId,
          body: UpdateLessonRequest(
            date: _asDay(date),
            students: _buildVisits(students, presentStudentIds),
          ),
        );

    // The attendance shown by the lesson page is loaded from the server and
    // has to be dropped once it changed.
    ref.invalidate(lessonDetailsProvider(lessonId));
  });

  Future<bool> deleteLesson({
    required String lessonId,
    required String groupId,
  }) => _mutate(
    groupId,
    () => ref.read(lessonServiceProvider).deleteLesson(lessonId: lessonId),
  );

  Future<bool> _mutate(String groupId, Future<void> Function() action) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await action();

      await ref.read(groupLessonsProvider(groupId).notifier).refresh();

      // The attendance of the lesson changed the statuses of the students the
      // student list shows, and the monthly report of the group.
      refreshAfterGroupLessonsMutation(ref);
    });

    return !state.hasError;
  }

  /// Sends a visit for every student of the group: the picked ones are present,
  /// the rest stay unmarked. The backend replaces the visits of the lesson with
  /// the sent list, so the complete group has to be included.
  List<StudentVisit> _buildVisits(
    List<GroupStudentSummaryResponse> students,
    Set<String> presentStudentIds,
  ) => students
      .map(
        (student) => presentStudentIds.contains(student.id)
            ? StudentVisit(
                studentId: student.id,
                status: VisitStatus.present,
                type: VisitType.regular,
              )
            : StudentVisit(
                studentId: student.id,
                status: VisitStatus.unmarked,
                type: VisitType.unmarked,
              ),
      )
      .toList();

  /// The backend stores lessons per day, so the time part is dropped.
  DateTime _asDay(DateTime date) => DateTime(date.year, date.month, date.day);
}
