import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/groups/pages/create_group_page.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/providers/groups_notifier.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupsPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    Consumer(
      builder: (context, ref, child) => IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () =>
            ref.read(groupsNotifierProvider.notifier).refreshGroups(),
      ),
    ),

    Consumer(
      builder: (context, ref, child) {
        final hasGroups = ref.watch(
          groupsNotifierProvider.select(
            (state) => state.value?.isNotEmpty ?? false,
          ),
        );

        if (!hasGroups) return const SizedBox.shrink();

        return IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            // Handle search
          },
        );
      },
    ),

    IconButton(
      icon: const Icon(Icons.create_new_folder_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      },
    ),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) {
      final groupsState = ref.watch(groupsNotifierProvider);

      return groupsState.when(
        data: (groups) {
          if (groups.isEmpty) {
            return EmptyState(
              buttonText: context.t.groups.createFirstGroup,
              subtitle: context.t.groups.emptySubtitle,
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupPage(),
                  ),
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
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupPage(group: group),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(groupsNotifierProvider.notifier).refreshGroups(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
