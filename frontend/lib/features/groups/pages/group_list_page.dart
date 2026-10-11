import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/widgets/create_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/features/groups/widgets/group_search_delegate.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  static final List<GroupSummaryResponse> _dummyGroups = List.generate(
    10,
    (index) => GroupSummaryResponse(
      id: 'placeholder-$index',
      name: 'Group Name Placeholder',
      createdAt: DateTime.now(),
      countOfStudents: 99,
    ),
  );

  @override
  List<Widget> actions(BuildContext context) => [
    Consumer(
      builder: (context, ref, child) {
        final groupsState = ref.watch(groupListControllerProvider);

        return IconButton(
          icon: const Icon(FluentIcons.search_24_regular),
          onPressed: () {
            final currentGroups = groupsState.value ?? [];

            showSearch(
              context: context,
              delegate: GroupSearchDelegate(
                currentGroups,
                '${MaterialLocalizations.of(context).searchFieldLabel}...',
              ),
            );
          },
        );
      },
    ),

    IconButton(
      icon: const Icon(FluentIcons.folder_add_24_regular),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateGroupBottomSheet(),
      ),
    ),

    const SizedBox(width: 8),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) {
      final groupsState = ref.watch(groupListControllerProvider);
      final isLoading = groupsState.isLoading;
      final hasError = groupsState.hasError;
      final groups = groupsState.value ?? [];

      return CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await ref
              .read(groupListControllerProvider.notifier)
              .getAllGroups(forceRefresh: true);

          // The group pages cache their lessons and students per group. The
          // refresh drops every one of those caches, so opening a group after
          // the refresh requests its data again instead of showing what was
          // loaded before.
          ref.invalidate(groupLessonsProvider);
          ref.invalidate(groupStudentsProvider);
        },
        child: _buildBody(
          context,
          ref,
          groupsState,
          groups,
          isLoading,
          hasError,
        ),
      );
    },
  );

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue groupsState,
    List<GroupSummaryResponse> groups,
    bool isLoading,
    bool hasError,
  ) {
    if (hasError && groups.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${groupsState.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref
                        .read(groupListControllerProvider.notifier)
                        .getAllGroups(),
                    child: Text(context.t.repeat),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!isLoading && groups.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: EmptyState(
              buttonText: context.t.groups.createFirstGroup,
              subtitle: context.t.groups.emptySubtitle,
              onButtonPressed: () => AppBottomSheet.show(
                context: context,
                child: const CreateGroupBottomSheet(),
              ),
            ),
          ),
        ),
      );
    }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: GroupListView(
        groups: isLoading && groups.isEmpty ? _dummyGroups : groups,
        isLoading: isLoading,
      ),
    );
  }
}
