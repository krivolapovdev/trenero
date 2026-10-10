import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final assignStudentGroupControllerProvider =
    AsyncNotifierProvider<AssignStudentGroupController, void>(
      AssignStudentGroupController.new,
    );

/// Moves a student to the group picked in the student group sheet.
class AssignStudentGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> assignGroup({
    required String studentId,
    required String groupId,
    required DateTime joinedAt,
    String? previousGroupId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(studentRepositoryProvider)
          .assignStudentGroup(
            studentId: studentId,
            groupId: groupId,
            joinedAt: joinedAt,
          );

      // The student card carries the group the student joined now, so the
      // list is reloaded before the sheet closes.
      await refreshAfterStudentMutation(ref);

      // The group the student joined counts one more student, the group they
      // left one less; their pages have to request the students again.
      refreshAfterStudentGroupChange(
        ref,
        groupId: groupId,
        previousGroupId: previousGroupId,
      );
    });

    return !state.hasError;
  }
}
