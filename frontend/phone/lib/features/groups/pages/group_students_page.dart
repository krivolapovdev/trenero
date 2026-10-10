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

/// Picks the students of a group on a full page.
///
/// The page lists every student with a checkbox and makes the picked ones the
/// students of the group, dropping the students that are left unchecked. A
/// group may end up without any student, so the update is always available.
class GroupStudentsPage extends ConsumerStatefulWidget {
  /// The group the picked students are assigned to.
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupStudentsPage> createState() => _GroupStudentsPageState();
}

class _GroupStudentsPageState extends ConsumerState<GroupStudentsPage> {
  /// Shown while the students are loading, before any student was fetched.
  static const List<String> _placeholderNames = [
    'Student Name Placeholder',
    'Student Name Placeholder',
    'Student Name Placeholder',
  ];

  /// The students the user picked, or `null` while the current students of the
  /// group are shown untouched.
  Set<String>? _pickedStudentIds;

  /// The students the checkboxes show selected.
  Set<String> _picked(Set<String> groupStudentIds) =>
      _pickedStudentIds ?? groupStudentIds;

  /// Picks a student, or drops the pick when the selected student is tapped
  /// again.
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
        AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
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
    final isLoading = studentsState.isLoading || groupStudentsState.isLoading;
    final hasError = studentsState.hasError;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.title),
        actions: [
          TextButton.icon(
            onPressed: isSubmitting ? null : () => _onSubmit(groupStudentIds),
            icon: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            label: Text(context.t.update, style: const TextStyle(fontSize: 18)),
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
