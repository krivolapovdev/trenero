import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/core/widgets/scrollable_fit.dart';
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

final List<GroupSummaryResponse> _dummyGroups = List.generate(
  10,
  (index) => GroupSummaryResponse(
    id: 'placeholder-$index',
    name: 'Group Name Placeholder',
    createdAt: DateTime.now(),
    countOfStudents: 99,
  ),
);

class GroupListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.folder_shared_outlined,
    super.selectedIcon = Icons.folder_shared,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    const _GroupSearchButton(),
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
    builder: (context, ref, child) => CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await ref
            .read(groupListControllerProvider.notifier)
            .getAllGroups(forceRefresh: true);

        ref
          ..invalidate(groupLessonsProvider)
          ..invalidate(groupStudentsProvider);
      },
      child: const _GroupListBody(),
    ),
  );
}

class _GroupSearchButton extends ConsumerWidget {
  const new();

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

class _GroupListBody extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupListControllerProvider);
    final isLoading = groupsState.isLoading;
    final groups = groupsState.value ?? const <GroupSummaryResponse>[];

    if (groupsState.hasError && groups.isEmpty) {
      return _GroupListRetry(error: groupsState.error);
    }

    if (!isLoading && groups.isEmpty) {
      return const _GroupListEmpty();
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

class _GroupListRetry extends ConsumerWidget {
  final Object? error;

  const new({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: '$error',
    scrollable: true,
    onRetry: () => ref.read(groupListControllerProvider.notifier).getAllGroups(),
  );
}

class _GroupListEmpty extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => ScrollableFit(
    child: EmptyState(
      buttonText: context.t.groups.createFirstGroup,
      subtitle: context.t.groups.emptySubtitle,
      onButtonPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateGroupBottomSheet(),
      ),
    ),
  );
}
