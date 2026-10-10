import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';

/// Reloads the group list in the background after a group was created or
/// edited.
///
/// The group cards are drawn from the list and the group page re-reads the
/// group it shows from it. The reload runs in the background because the list
/// loads with a delay the sheet that changed the group should not wait for.
void refreshAfterGroupMutation(Ref ref) {
  unawaited(
    ref
        .read(groupListControllerProvider.notifier)
        .getAllGroups(forceRefresh: true)
        .catchError((error, _) {
          log('Error refreshing the groups after a group mutation: $error');
        }),
  );
}

/// Reloads the data a change of the lessons of a group side effects.
///
/// The attendance of a lesson changes the statuses of the students, which the
/// student list shows, so the list is reloaded in the background. The monthly
/// reports of the group are dropped, so they are requested again the next time
/// a report is opened.
void refreshAfterGroupLessonsMutation(Ref ref) {
  ref.invalidate(groupReportProvider);

  unawaited(
    ref
        .read(studentListControllerProvider.notifier)
        .getAllStudents(forceRefresh: true)
        .catchError((error, _) {
          log(
            'Error refreshing the students after a group lesson change: $error',
          );
        }),
  );
}

/// Reloads the data a change of the students of a group side effects.
///
/// The group page caches the students of its group, the group list counts them
/// and the student list carries the groups every student belongs to. The group
/// students are dropped right away, so the group page requests them again; the
/// two lists are reloaded in the background.
void refreshAfterGroupStudentsMutation(Ref ref, {required String groupId}) {
  ref.invalidate(groupStudentsProvider(groupId));

  refreshAfterGroupMutation(ref);

  unawaited(
    ref
        .read(studentListControllerProvider.notifier)
        .getAllStudents(forceRefresh: true)
        .catchError((error, _) {
          log(
            'Error refreshing the students after a group student change: $error',
          );
        }),
  );
}
