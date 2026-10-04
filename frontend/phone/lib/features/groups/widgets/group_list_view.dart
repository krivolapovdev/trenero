import 'package:flutter/material.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_summary.dart';

class GroupListView extends StatelessWidget {
  final List<GroupSummary> groups;
  final bool isLoading;

  const new({super.key, required this.groups, this.isLoading = false});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16.0),
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    itemCount: groups.length,
    itemBuilder: (context, index) {
      final group = groups[index];

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Hero(
          tag: 'group-card-${group.id}',
          child: Material(
            type: MaterialType.transparency,
            child: GroupCard(
              group: group,
              onTap: isLoading
                  ? () {}
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupPage(group: group),
                        ),
                      );
                    },
            ),
          ),
        ),
      );
    },
  );
}
