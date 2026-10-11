import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';

final deleteGroupControllerProvider =
    AsyncNotifierProvider<DeleteGroupController, void>(
      DeleteGroupController.new,
    );

/// Deletes a group of the trainer.
///
/// The group is gone from the server, so every page that cached it drops what
/// it held: the lessons and the monthly reports of the group are dropped, the
/// group list is reloaded in the background and the groups the students carry
/// are read again.
class DeleteGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteGroup(String groupId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(groupRepositoryProvider).deleteGroup(groupId);

      ref.invalidate(groupLessonsProvider(groupId));
      ref.invalidate(groupReportProvider);

      refreshAfterGroupStudentsMutation(ref, groupId: groupId);
    });

    return !state.hasError;
  }
}
