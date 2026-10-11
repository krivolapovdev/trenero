import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/groups/controllers/assign_group_students_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

final List<StudentSummaryResponse> _placeholderStudents = List.generate(
  3,
  (index) => StudentSummaryResponse(
    id: 'placeholder-$index',
    fullName: 'Student Name Placeholder',
    createdAt: DateTime.now(),
    free: false,
    statuses: const [],
  ),
);

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
          _AssignStudentsButton(
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
      body: _GroupStudentsBody(
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

class _AssignStudentsButton extends ConsumerWidget {
  final bool hasChanges;
  final VoidCallback onSubmit;

  const new({required this.hasChanges, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      assignGroupStudentsControllerProvider.select((state) => state.isLoading),
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

class _GroupStudentsBody extends StatelessWidget {
  final List<StudentSummaryResponse> students;
  final Set<String> pickedStudentIds;
  final bool isLoading;
  final bool hasError;
  final Object? error;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const new({
    required this.students,
    required this.pickedStudentIds,
    required this.isLoading,
    required this.hasError,
    required this.onToggle,
    required this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError && students.isEmpty) {
      return RetryView(message: '$error', onRetry: onRetry);
    }

    if (!isLoading && students.isEmpty) {
      return const _GroupStudentsEmpty();
    }

    final displayStudents = students.isEmpty ? _placeholderStudents : students;

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
              itemCount: displayStudents.length,
              itemBuilder: (context, index) {
                final student = displayStudents[index];

                return _StudentCheckboxTile(
                  key: ValueKey(student.id),
                  student: student,
                  selected: pickedStudentIds.contains(student.id),
                  enabled: !isLoading,
                  onToggle: () => onToggle(student.id),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentCheckboxTile extends StatelessWidget {
  final StudentSummaryResponse student;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const new({
    super.key,
    required this.student,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: selected,
    onChanged: enabled ? (_) => onToggle() : null,
    title: Text(
      student.fullName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  );
}

class _GroupStudentsEmpty extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      context.t.students.emptySubtitle,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
