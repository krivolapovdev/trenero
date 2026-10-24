import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/widgets/create_roster_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/roster_list_body.dart';
import 'package:phone/features/rosters/widgets/roster_search_button.dart';
import 'package:phone/i18n/strings.g.dart';

class RosterListPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosters = ref.watch(rosterListControllerProvider).value;
    final count = rosters?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t.titleWithCount(
            title: context.t.rosters.title,
            count: count.toString(),
          ),
        ),
        actions: [
          const RosterSearchButton(),
          IconButton(
            icon: const Icon(FluentIcons.add_24_regular),
            onPressed: () => AppBottomSheet.show(
              context: context,
              child: const CreateRosterBottomSheet(),
            ),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await ref
              .read(rosterListControllerProvider.notifier)
              .getAllRosters(forceRefresh: true);
        },
        child: const RosterListBody(),
      ),
    );
  }
}
