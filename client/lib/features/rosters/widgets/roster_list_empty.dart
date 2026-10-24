import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/scrollable_fit.dart';
import 'package:phone/features/rosters/widgets/create_roster_bottom_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class RosterListEmpty extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => ScrollableFit(
    child: EmptyState(
      buttonText: context.t.rosters.createFirstRoster,
      subtitle: context.t.rosters.emptySubtitle,
      onButtonPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateRosterBottomSheet(),
      ),
    ),
  );
}
