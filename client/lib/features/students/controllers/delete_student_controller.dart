import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final deleteStudentControllerProvider =
    AsyncNotifierProvider<DeleteStudentController, void>(
      DeleteStudentController.new,
    );

class DeleteStudentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteStudent(String studentId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(studentRepositoryProvider).deleteStudent(studentId);

      ref
        ..invalidate(studentLessonsProvider(studentId))
        ..invalidate(studentPaymentsControllerProvider(studentId))
        ..invalidate(groupStudentsProvider)
        ..invalidate(groupReportProvider);

      await Future.wait([
        ref
            .read(studentListControllerProvider.notifier)
            .getAllStudents(forceRefresh: true),
        ref
            .read(groupListControllerProvider.notifier)
            .getAllGroups(forceRefresh: true),
      ]);
    });

    return !state.hasError;
  }
}
