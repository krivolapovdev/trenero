import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';

Future<void> refreshAfterStudentMutation(Ref ref) async {
  await ref
      .read(studentListControllerProvider.notifier)
      .getAllStudents(forceRefresh: true);
}

void refreshAfterStudentGroupChange(
  Ref ref, {
  required Set<String> groupIds,
  Set<String> previousGroupIds = const <String>{},
}) {
  unawaited(
    ref
        .read(groupListControllerProvider.notifier)
        .getAllGroups(forceRefresh: true)
        .catchError((error, _) {
          log('Error refreshing the groups after a student was moved: $error');
        }),
  );

  for (final groupId in {...previousGroupIds, ...groupIds}) {
    ref.invalidate(groupStudentsProvider(groupId));
  }
}
