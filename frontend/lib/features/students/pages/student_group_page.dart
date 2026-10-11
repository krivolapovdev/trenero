import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/features/students/widgets/student_groups_body.dart';
import 'package:phone/features/students/widgets/submit_groups_button.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

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
          SubmitGroupsButton(hasChanges: _hasChanges, onSubmit: _onSubmit),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: StudentGroupsBody(
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
