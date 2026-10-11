import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';

final groupStudentsProvider =
    AsyncNotifierProvider.family<
      GroupStudentsController,
      List<GroupStudentSummaryResponse>,
      String
    >(GroupStudentsController.new);

class GroupStudentsController
    extends AsyncNotifier<List<GroupStudentSummaryResponse>> {
  new(this.groupId);

  final String groupId;

  @override
  Future<List<GroupStudentSummaryResponse>> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    return repository.getGroupStudents(groupId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await Future.delayed(Duration(seconds: 3));
    state = await AsyncValue.guard(build);
  }
}
