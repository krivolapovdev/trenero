import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/models/student_summary_response.dart';

final studentListControllerProvider =
    AsyncNotifierProvider<StudentListController, List<StudentSummaryResponse>>(
      StudentListController.new,
    );

final filteredStudentsProvider = Provider<List<StudentSummaryResponse>>((ref) {
  final students = ref.watch(studentListControllerProvider).value;
  if (students == null) return const <StudentSummaryResponse>[];

  final filter = ref.watch(studentFilterControllerProvider);

  return students.where(filter.matches).toList(growable: false);
});

class StudentListController
    extends AsyncNotifier<List<StudentSummaryResponse>> {
  @override
  Future<List<StudentSummaryResponse>> build() async {
    final repository = ref.watch(studentRepositoryProvider);
    return repository.getAllStudents(forceRefresh: true);
  }

  Future<void> getAllStudents({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(studentRepositoryProvider)
          .getAllStudents(forceRefresh: forceRefresh),
    );
  }
}
