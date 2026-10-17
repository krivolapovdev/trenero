import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/widgets/group_list_dummy_groups.dart';
import 'package:phone/features/groups/widgets/group_list_empty.dart';
import 'package:phone/features/groups/widgets/group_list_retry.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupListBody extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupListControllerProvider);
    final isLoading = groupsState.isLoading;
    final groups = groupsState.value ?? const <GroupSummaryResponse>[];

    if (groupsState.hasError && groups.isEmpty) {
      return GroupListRetry(error: groupsState.error);
    }

    if (!isLoading && groups.isEmpty) {
      return const GroupListEmpty();
    }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: GroupListView(
        groups: isLoading && groups.isEmpty ? groupListDummyGroups : groups,
        isLoading: isLoading,
      ),
    );
  }
}
