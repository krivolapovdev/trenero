import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final assignStudentGroupControllerProvider =
    AsyncNotifierProvider<AssignStudentGroupController, void>(
      AssignStudentGroupController.new,
    );

/// Moves a student to the groups picked in the student group page.
class AssignStudentGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> assignGroups({
    required String studentId,
    required Set<String> groupIds,
    Set<String> previousGroupIds = const <String>{},
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(studentRepositoryProvider)
          .assignStudentGroups(studentId: studentId, groupIds: groupIds);

      // The student card carries the groups the student joined now, so the
      // list is reloaded before the page closes.
      await refreshAfterStudentMutation(ref);

      // Every group the student joined counts one more student, every group
      // they left one less; their pages have to request the students again.
      refreshAfterStudentGroupChange(
        ref,
        groupIds: groupIds,
        previousGroupIds: previousGroupIds,
      );
    });

    return !state.hasError;
  }
}
