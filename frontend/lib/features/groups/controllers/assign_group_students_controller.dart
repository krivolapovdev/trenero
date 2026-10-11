import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';

final assignGroupStudentsControllerProvider =
    AsyncNotifierProvider<AssignGroupStudentsController, void>(
      AssignGroupStudentsController.new,
    );

class AssignGroupStudentsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> assignStudents({
    required String groupId,
    required Set<String> studentIds,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(groupRepositoryProvider)
          .setGroupStudents(groupId: groupId, studentIds: studentIds);

      refreshAfterGroupStudentsMutation(ref, groupId: groupId);
    });

    return !state.hasError;
  }
}
