import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/group_summary_response.dart';

final groupListControllerProvider =
    AsyncNotifierProvider<GroupListController, List<GroupSummaryResponse>>(
      GroupListController.new,
    );

class GroupListController extends AsyncNotifier<List<GroupSummaryResponse>> {
  @override
  Future<List<GroupSummaryResponse>> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    return repository.getAllGroups(forceRefresh: true);
  }

  Future<void> getAllGroups({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    await Future.delayed(const Duration(seconds: 3));

    state = await AsyncValue.guard(
      () => ref
          .read(groupRepositoryProvider)
          .getAllGroups(forceRefresh: forceRefresh),
    );
  }
}
