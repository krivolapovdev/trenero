import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';

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

void refreshAfterGroupLessonsMutation(
  Ref ref, {
  required String groupId,
  required Iterable<String> studentIds,
}) {
  ref
    ..invalidate(groupReportProvider)
    ..invalidate(groupStudentsProvider(groupId));

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

  for (final studentId in studentIds) {
    final provider = studentLessonsProvider(studentId);
    if (!ref.exists(provider)) continue;

    unawaited(
      ref.read(provider.notifier).refresh().catchError((error, _) {
        log(
          'Error refreshing the page of student $studentId after a group lesson change: $error',
        );
      }),
    );
  }
}

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
