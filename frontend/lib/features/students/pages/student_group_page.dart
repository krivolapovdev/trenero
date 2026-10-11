import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  static const List<String> _placeholderNames = [
    'Group Name Placeholder',
    'Group Name Placeholder',
    'Group Name Placeholder',
  ];

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
    final isSubmitting = ref
        .watch(assignStudentGroupControllerProvider)
        .isLoading;
    final isLoading = groupsState.isLoading;
    final hasError = groupsState.hasError;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.group),
        actions: [
          TextButton.icon(
            onPressed: (!_hasChanges || isSubmitting) ? null : _onSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            label: Text(context.t.edit, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _buildBody(context, groups, isLoading, hasError),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<GroupSummaryResponse> groups,
    bool isLoading,
    bool hasError,
  ) {
    if (hasError && groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${ref.read(groupListControllerProvider).error}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(groupListControllerProvider.notifier).getAllGroups(),
              child: Text(context.t.repeat),
            ),
          ],
        ),
      );
    }

    if (!isLoading && groups.isEmpty) {
      return Center(
        child: Text(
          context.t.groups.emptySubtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final displayGroups = groups.isEmpty
        ? _placeholderNames
              .map(
                (name) => GroupSummaryResponse(
                  id: name,
                  name: name,
                  createdAt: DateTime.now(),
                ),
              )
              .toList()
        : groups;

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
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: displayGroups
                  .map(
                    (group) => CheckboxListTile(
                      value: _groupIds.contains(group.id),
                      onChanged: isLoading
                          ? null
                          : (_) => _toggleGroup(group.id),
                      title: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
