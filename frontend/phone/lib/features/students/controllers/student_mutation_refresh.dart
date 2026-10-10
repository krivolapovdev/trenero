import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';

/// Reloads the student list after a student was created, edited or moved to
/// another group.
///
/// The student cards are drawn from the list: it carries the group of the
/// student and the status badges, both of which a mutation can change. The
/// reload is awaited so that a caller reading the list right after the mutation
/// (the page the sheet was opened from) sees the new data.
Future<void> refreshAfterStudentMutation(Ref ref) async {
  await ref
      .read(studentListControllerProvider.notifier)
      .getAllStudents(forceRefresh: true);
}

/// Reloads the group data a move of a student between groups changes.
///
/// Both the group the student joined and the group they left count a different
/// number of students, and both group pages cache the students of their group.
/// The group list is reloaded in the background because it loads with a delay
/// the sheet that moved the student should not wait for; the affected group
/// student caches are dropped right away so their pages request the students
/// again.
void refreshAfterStudentGroupChange(
  Ref ref, {
  required String groupId,
  String? previousGroupId,
}) {
  unawaited(
    ref
        .read(groupListControllerProvider.notifier)
        .getAllGroups(forceRefresh: true)
        .catchError((error, _) {
          log('Error refreshing the groups after a student was moved: $error');
        }),
  );

  ref.invalidate(groupStudentsProvider(groupId));

  if (previousGroupId != null && previousGroupId != groupId) {
    ref.invalidate(groupStudentsProvider(previousGroupId));
  }
}
