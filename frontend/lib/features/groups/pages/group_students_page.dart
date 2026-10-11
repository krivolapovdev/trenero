import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/assign_group_students_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/widgets/assign_students_button.dart';
import 'package:phone/features/groups/widgets/group_students_body.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupStudentsPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupStudentsPage> createState() => _GroupStudentsPageState();
}

class _GroupStudentsPageState extends ConsumerState<GroupStudentsPage> {
  Set<String>? _pickedStudentIds;

  Set<String> _picked(Set<String> groupStudentIds) =>
      _pickedStudentIds ?? groupStudentIds;

  bool _hasChanges(Set<String> groupStudentIds) {
    final pickedStudentIds = _pickedStudentIds;
    if (pickedStudentIds == null) return false;

    return pickedStudentIds.length != groupStudentIds.length ||
        !pickedStudentIds.containsAll(groupStudentIds);
  }

  void _toggleStudent(Set<String> groupStudentIds, String studentId) {
    setState(() {
      final next = {..._picked(groupStudentIds)};
      if (!next.remove(studentId)) next.add(studentId);
      _pickedStudentIds = next;
    });
  }

  Future<void> _onSubmit(Set<String> groupStudentIds) async {
    final studentIds = _picked(groupStudentIds);

    final success = await ref
        .read(assignGroupStudentsControllerProvider.notifier)
        .assignStudents(groupId: widget.group.id, studentIds: studentIds);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(assignGroupStudentsControllerProvider).error;
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
    final studentsState = ref.watch(studentListControllerProvider);
    final students = studentsState.value ?? const <StudentSummaryResponse>[];
    final groupStudentsState = ref.watch(
      groupStudentsProvider(widget.group.id),
    );
    final groupStudentIds =
        groupStudentsState.value?.map((student) => student.id).toSet() ??
        const <String>{};
    final pickedStudentIds = _picked(groupStudentIds);
    final hasChanges = _hasChanges(groupStudentIds);
    final isLoading = studentsState.isLoading || groupStudentsState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.title),
        actions: [
          AssignStudentsButton(
            hasChanges: hasChanges,
            onSubmit: () => _onSubmit(groupStudentIds),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: GroupStudentsBody(
        students: students,
        pickedStudentIds: pickedStudentIds,
        isLoading: isLoading,
        hasError: studentsState.hasError,
        error: studentsState.error,
        onToggle: (studentId) => _toggleStudent(groupStudentIds, studentId),
        onRetry: () => ref
            .read(studentListControllerProvider.notifier)
            .getAllStudents(forceRefresh: true),
      ),
    );
  }
}
