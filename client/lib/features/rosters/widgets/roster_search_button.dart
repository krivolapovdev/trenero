import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/widgets/roster_search_delegate.dart';
import 'package:phone/generated/models/roster_response.dart';

class RosterSearchButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRosters = ref.watch(
      rosterListControllerProvider.select(
        (state) => state.value ?? const <RosterResponse>[],
      ),
    );

    return IconButton(
      icon: const Icon(FluentIcons.search_24_regular),
      onPressed: () {
        showSearch(
          context: context,
          delegate: RosterSearchDelegate(
            currentRosters,
            '${MaterialLocalizations.of(context).searchFieldLabel}...',
          ),
        );
      },
    );
  }
}
