import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

final List<GroupSummaryResponse> _placeholderGroups = List.generate(
  3,
  (index) => GroupSummaryResponse(
    id: 'placeholder-$index',
    name: 'Group Name Placeholder',
    createdAt: DateTime.now(),
  ),
);

class StudentGroupPage extends ConsumerStatefulWidget {
  final String studentId;

  final Set<String> initialGroupIds;

  const new({
    super.key,
    required this.studentId,
    this.initialGroupIds = const <String>{},
  });

  @override
  ConsumerState<StudentGroupPage> createState() => _StudentGroupPageState();
}

class _StudentGroupPageState extends ConsumerState<StudentGroupPage> {
  late final Set<String> _groupIds = {...widget.initialGroupIds};

  bool get _hasChanges =>
      _groupIds.length != widget.initialGroupIds.length ||
      !_groupIds.containsAll(widget.initialGroupIds);

  void _toggleGroup(String groupId) {
    setState(() {
      if (!_groupIds.remove(groupId)) {
        _groupIds.add(groupId);
      }
    });
  }

  Future<void> _onSubmit() async {
    final groupIds = _groupIds.toSet();

    final success = await ref
        .read(assignStudentGroupControllerProvider.notifier)
        .assignGroups(
          studentId: widget.studentId,
          groupIds: groupIds,
          previousGroupIds: widget.initialGroupIds,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(assignStudentGroupControllerProvider).error;
      if (error != null) {
        AppSnackBar.show(
          context,
          '${context.t.error}: $error',
          SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupListControllerProvider);
    final groups = groupsState.value ?? const <GroupSummaryResponse>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.group),
        actions: [
          _SubmitGroupsButton(hasChanges: _hasChanges, onSubmit: _onSubmit),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: _StudentGroupsBody(
        groups: groups,
        selectedGroupIds: _groupIds,
        isLoading: groupsState.isLoading,
        hasError: groupsState.hasError,
        error: groupsState.error,
        onToggle: _toggleGroup,
        onRetry: () =>
            ref.read(groupListControllerProvider.notifier).getAllGroups(),
      ),
    );
  }
}

class _SubmitGroupsButton extends ConsumerWidget {
  final bool hasChanges;
  final VoidCallback onSubmit;

  const new({required this.hasChanges, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      assignStudentGroupControllerProvider.select((state) => state.isLoading),
    );

    return TextButton.icon(
      onPressed: (!hasChanges || isSubmitting) ? null : onSubmit,
      icon: isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      label: Text(context.t.edit, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _StudentGroupsBody extends StatelessWidget {
  final List<GroupSummaryResponse> groups;
  final Set<String> selectedGroupIds;
  final bool isLoading;
  final bool hasError;
  final Object? error;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const new({
    required this.groups,
    required this.selectedGroupIds,
    required this.isLoading,
    required this.hasError,
    required this.onToggle,
    required this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError && groups.isEmpty) {
      return RetryView(message: '$error', onRetry: onRetry);
    }

    if (!isLoading && groups.isEmpty) return const _StudentGroupsEmpty();

    final displayGroups = groups.isEmpty ? _placeholderGroups : groups;

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: displayGroups.length,
              itemBuilder: (context, index) {
                final group = displayGroups[index];

                return _GroupCheckboxTile(
                  key: ValueKey(group.id),
                  group: group,
                  selected: selectedGroupIds.contains(group.id),
                  enabled: !isLoading,
                  onToggle: () => onToggle(group.id),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupCheckboxTile extends StatelessWidget {
  final GroupSummaryResponse group;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const new({
    super.key,
    required this.group,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: selected,
    onChanged: enabled ? (_) => onToggle() : null,
    title: Text(
      group.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  );
}

class _StudentGroupsEmpty extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.t.groups.emptySubtitle,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
