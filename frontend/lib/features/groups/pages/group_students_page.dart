import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/assign_group_students_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupStudentsPage extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupStudentsPage> createState() => _GroupStudentsPageState();
}

class _GroupStudentsPageState extends ConsumerState<GroupStudentsPage> {
  static const List<String> _placeholderNames = [
    'Student Name Placeholder',
    'Student Name Placeholder',
    'Student Name Placeholder',
  ];

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
    final isSubmitting = ref
        .watch(assignGroupStudentsControllerProvider)
        .isLoading;
    final hasChanges = _hasChanges(groupStudentIds);
    final isLoading = studentsState.isLoading || groupStudentsState.isLoading;
    final hasError = studentsState.hasError;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.title),
        actions: [
          TextButton.icon(
            onPressed: (isSubmitting || !hasChanges)
                ? null
                : () => _onSubmit(groupStudentIds),
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
      body: _buildBody(
        context,
        students,
        pickedStudentIds,
        isLoading,
        hasError,
        groupStudentIds,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<StudentSummaryResponse> students,
    Set<String> pickedStudentIds,
    bool isLoading,
    bool hasError,
    Set<String> groupStudentIds,
  ) {
    if (hasError && students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${ref.read(studentListControllerProvider).error}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(studentListControllerProvider.notifier)
                  .getAllStudents(forceRefresh: true),
              child: Text(context.t.repeat),
            ),
          ],
        ),
      );
    }

    if (!isLoading && students.isEmpty) {
      return Center(
        child: Text(
          context.t.students.emptySubtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final displayStudents = students.isEmpty
        ? _placeholderNames
              .map(
                (name) => StudentSummaryResponse(
                  id: name,
                  fullName: name,
                  createdAt: DateTime.now(),
                  free: false,
                  statuses: const [],
                ),
              )
              .toList()
        : students;

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
              children: displayStudents
                  .map(
                    (student) => CheckboxListTile(
                      value: pickedStudentIds.contains(student.id),
                      onChanged: isLoading
                          ? null
                          : (_) => _toggleStudent(groupStudentIds, student.id),
                      title: Text(
                        student.fullName,
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
