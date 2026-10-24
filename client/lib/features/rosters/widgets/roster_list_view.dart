import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/rosters/pages/roster_details_page.dart';
import 'package:phone/features/rosters/widgets/edit_roster_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/roster_card.dart';
import 'package:phone/generated/models/roster_response.dart';

class RosterListView extends StatelessWidget {
  final List<RosterResponse> rosters;
  final bool isLoading;

  const new({super.key, required this.rosters, this.isLoading = false});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16.0),
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
    itemCount: rosters.length,
    itemBuilder: (context, index) {
      final roster = rosters[index];

      return Hero(
        tag: 'roster-card-${roster.id}',
        child: Material(
          type: MaterialType.transparency,
          child: RosterCard(
            roster: roster,
            onTap: isLoading
                ? () {}
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RosterDetailsPage(roster: roster),
                      ),
                    );
                  },
            onLongPress: isLoading
                ? null
                : () => AppBottomSheet.show(
                    context: context,
                    child: EditRosterBottomSheet(roster: roster),
                  ),
          ),
        ),
      );
    },
  );
}
