import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/groups/pages/create_group_page.dart';
import 'package:phone/features/groups/providers/groups_notifier.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/features/groups/widgets/group_search_delegate.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    Consumer(
      builder: (context, ref, child) {
        final groupsState = ref.watch(groupsNotifierProvider);

        return IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            final currentGroups = groupsState.value ?? [];

            showSearch(
              context: context,
              delegate: GroupSearchDelegate(
                currentGroups,
                '${context.t.search}...',
              ),
            );
          },
        );
      },
    ),

    Consumer(
      builder: (context, ref, child) => IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () =>
            ref.read(groupsNotifierProvider.notifier).refreshGroups(),
      ),
    ),

    IconButton(
      icon: const Icon(Icons.create_new_folder_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      },
    ),

    const SizedBox(width: 8),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) => CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await ref.read(groupsNotifierProvider.notifier).refreshGroups();
      },
      child: Consumer(
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

              return GroupListView(groups: groups);
            },

            loading: () => const Center(),

            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref
                        .read(groupsNotifierProvider.notifier)
                        .refreshGroups(),
                    child: Text(context.t.repeat),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
