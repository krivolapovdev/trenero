import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/groups/pages/create_group_page.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/providers/groups_providers.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) {
      final groupsState = ref.watch(groupsNotifierProvider);
      final groups = groupsState.allGroups.values.toList();

      if (groups.isEmpty && !groupsState.isRefreshing) {
        return EmptyState(
          buttonText: context.t.groups.createFirstGroup,
          subtitle: context.t.groups.emptySubtitle,
          onButtonPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateGroupPage()),
            );
          },
        );
      }

      return CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () =>
            ref.read(groupsNotifierProvider.notifier).refreshGroups(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Hero(
                  tag: 'group-card-${group.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: GroupCard(
                      group: group,
                      onTap: () {
                        pushWithoutNavBar(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupPage(group: group),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
