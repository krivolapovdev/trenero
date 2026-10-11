import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final assignStudentGroupControllerProvider =
    AsyncNotifierProvider<AssignStudentGroupController, void>(
      AssignStudentGroupController.new,
    );

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

      await refreshAfterStudentMutation(ref);

      refreshAfterStudentGroupChange(
        ref,
        groupIds: groupIds,
        previousGroupIds: previousGroupIds,
      );
    });

    return !state.hasError;
  }
}
