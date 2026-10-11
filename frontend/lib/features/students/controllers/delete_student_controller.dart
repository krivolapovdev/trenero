import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Deletes a student of the trainer.
///
/// The student is gone from the server, so every page that cached them drops
/// what it held: the lessons and the payments of the student are dropped, the
/// group pages read their students again, the monthly reports of the groups are
/// read again and the student list loses the card.
class DeleteStudentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteStudent(String studentId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(studentRepositoryProvider).deleteStudent(studentId);

      ref.invalidate(studentLessonsProvider(studentId));
      ref.invalidate(studentPaymentsControllerProvider(studentId));
      ref.invalidate(groupStudentsProvider);
      ref.invalidate(groupReportProvider);

      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);
    });

    return !state.hasError;
  }
}
