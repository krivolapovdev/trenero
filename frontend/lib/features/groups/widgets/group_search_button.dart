import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/widgets/group_search_delegate.dart';
import 'package:phone/generated/models/group_summary_response.dart';

class GroupSearchButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGroups = ref.watch(
      groupListControllerProvider.select(
        (state) => state.value ?? const <GroupSummaryResponse>[],
      ),
    );

    return IconButton(
      icon: const Icon(FluentIcons.search_24_regular),
      onPressed: () {
        showSearch(
          context: context,
          delegate: GroupSearchDelegate(
            currentGroups,
            '${MaterialLocalizations.of(context).searchFieldLabel}...',
          ),
        );
      },
    );
  }
}
