import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/group_response.dart';

final groupsNotifierProvider =
    AsyncNotifierProvider<GroupsNotifier, List<GroupResponse>>(
      GroupsNotifier.new,
    );

class GroupsNotifier extends AsyncNotifier<List<GroupResponse>> {
  @override
  Future<List<GroupResponse>> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    return repository.getAllGroups();
  }

  Future<void> refreshGroups() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(groupRepositoryProvider).getAllGroups(),
    );
  }
}
