import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    });

    return !state.hasError;
  }
}
