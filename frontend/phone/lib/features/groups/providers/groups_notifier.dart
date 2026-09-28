import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/group_summary.dart';

final groupsNotifierProvider =
    AsyncNotifierProvider<GroupsNotifier, List<GroupSummary>>(
      GroupsNotifier.new,
    );

class GroupsNotifier extends AsyncNotifier<List<GroupSummary>> {
  @override
  Future<List<GroupSummary>> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    return repository.getAllGroups();
  }

  Future<void> refreshGroups() async {
    state = const AsyncLoading();

    await Future.delayed(const Duration(seconds: 3));

    state = await AsyncValue.guard(
      () => ref.read(groupRepositoryProvider).getAllGroups(),
    );
  }
}
