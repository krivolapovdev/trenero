import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/export.dart';

final studentLessonsProvider =
    AsyncNotifierProvider.family<
      StudentLessonsController,
      List<VisitWithLessonResponse>,
      String
    >(StudentLessonsController.new);

class StudentLessonsController
    extends AsyncNotifier<List<VisitWithLessonResponse>> {
  new(this.studentId);

  final String studentId;

  @override
  Future<List<VisitWithLessonResponse>> build() async {
    final from = DateTime(2000, 1, 1);
    final to = DateTime.now();

    final repository = ref.watch(studentRepositoryProvider);
    return repository.getStudentVisits(
      studentId: studentId,
      from: from,
      to: to,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
