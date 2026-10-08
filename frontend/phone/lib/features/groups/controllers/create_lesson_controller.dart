import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/student_visit.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';

final createLessonControllerProvider =
    AsyncNotifierProvider<CreateLessonController, void>(
      CreateLessonController.new,
    );

class CreateLessonController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Creates a lesson of [groupId] on [date] and marks every student of
  /// [studentIds] as a regular present visitor. The remaining students of the
  /// group are added by the backend as unmarked visits.
  Future<bool> saveLesson({
    required String groupId,
    required DateTime date,
    required Set<String> studentIds,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final request = CreateLessonRequest(
        groupId: groupId,
        date: DateTime(date.year, date.month, date.day),
        students: studentIds
            .map(
              (studentId) => StudentVisit(
                studentId: studentId,
                status: VisitStatus.present,
                type: VisitType.regular,
              ),
            )
            .toList(),
      );

      final service = ref.read(lessonServiceProvider);
      await service.createLesson(body: request);

      await ref.read(groupLessonsProvider(groupId).notifier).refresh();
    });

    return !state.hasError;
  }
}
