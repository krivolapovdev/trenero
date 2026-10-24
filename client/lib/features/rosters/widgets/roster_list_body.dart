import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/widgets/roster_list_dummy_rosters.dart';
import 'package:phone/features/rosters/widgets/roster_list_empty.dart';
import 'package:phone/features/rosters/widgets/roster_list_retry.dart';
import 'package:phone/features/rosters/widgets/roster_list_view.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RosterListBody extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rostersState = ref.watch(rosterListControllerProvider);
    final isLoading = rostersState.isLoading;
    final rosters = rostersState.value ?? const <RosterResponse>[];

    if (rostersState.hasError && rosters.isEmpty) {
      return RosterListRetry(error: rostersState.error);
    }

    if (!isLoading && rosters.isEmpty) {
      return const RosterListEmpty();
    }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: RosterListView(
        rosters: isLoading && rosters.isEmpty
            ? rosterListDummyRosters
            : rosters,
        isLoading: isLoading,
      ),
    );
  }
}
