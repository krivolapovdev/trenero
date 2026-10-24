import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';
import 'package:phone/generated/models/student_response.dart';

final rosterStudentsProvider =
    AsyncNotifierProvider.family<
      RosterStudentsController,
      List<StudentResponse>,
      String
    >(RosterStudentsController.new);

class RosterStudentsController extends AsyncNotifier<List<StudentResponse>> {
  new(this.rosterId);

  final String rosterId;

  @override
  Future<List<StudentResponse>> build() async {
    final repository = ref.watch(rosterRepositoryProvider);
    return repository.getRosterStudents(rosterId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  Future<bool> addStudents(List<String> studentIds, {String? note}) async {
    final repository = ref.read(rosterRepositoryProvider);
    final prev = state.value ?? [];

    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() async {
      await repository.addStudentsToRoster(
        rosterId: rosterId,
        studentIds: studentIds,
        note: note,
      );
      return repository.getRosterStudents(rosterId);
    });

    if (res.hasError) {
      state = AsyncValue.data(prev);
      return false;
    }

    state = res;
    ref
        .read(rosterListControllerProvider.notifier)
        .getAllRosters(forceRefresh: true);
    return true;
  }

  Future<bool> updateStudentNote(String studentId, String? note) async {
    final repository = ref.read(rosterRepositoryProvider);
    final prev = state.value ?? [];

    state = const AsyncValue.loading();
    final res = await AsyncValue.guard(() async {
      await repository.updateRosterStudentNote(
        rosterId: rosterId,
        studentId: studentId,
        note: note,
      );
      return repository.getRosterStudents(rosterId);
    });

    if (res.hasError) {
      state = AsyncValue.data(prev);
      return false;
    }

    state = res;
    return true;
  }

  Future<bool> removeStudent(String studentId) async {
    final repository = ref.read(rosterRepositoryProvider);
    final prev = state.value ?? [];
    // optimistic update: remove the first instance of studentId
    final index = prev.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final updated = List<StudentResponse>.from(prev)..removeAt(index);
      state = AsyncValue.data(updated);
    }

    final res = await AsyncValue.guard(() async {
      await repository.removeStudentFromRoster(
        rosterId: rosterId,
        studentId: studentId,
      );
    });

    if (res.hasError) {
      state = AsyncValue.data(prev);
      return false;
    }

    ref
        .read(rosterListControllerProvider.notifier)
        .getAllRosters(forceRefresh: true);
    return true;
  }
}
