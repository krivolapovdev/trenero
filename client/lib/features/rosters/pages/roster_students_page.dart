import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/widgets/assign_students_button.dart';
import 'package:phone/features/groups/widgets/student_checkbox_tile.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/controllers/roster_students_controller.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RosterStudentsPage extends ConsumerStatefulWidget {
  final RosterResponse roster;

  const new({super.key, required this.roster});

  @override
  ConsumerState<RosterStudentsPage> createState() => _RosterStudentsPageState();
}

class _RosterStudentsPageState extends ConsumerState<RosterStudentsPage> {
  Set<String>? _pickedStudentIds;
  bool _isSubmitting = false;

  Set<String> _picked(Set<String> initialIds) =>
      _pickedStudentIds ?? initialIds;

  bool _hasChanges(Set<String> initialIds) {
    final picked = _pickedStudentIds;
    if (picked == null) return false;

    return picked.length != initialIds.length ||
        !picked.containsAll(initialIds);
  }

  void _toggleStudent(Set<String> initialIds, String studentId) {
    setState(() {
      final next = {..._picked(initialIds)};
      if (!next.remove(studentId)) {
        next.add(studentId);
      }
      _pickedStudentIds = next;
    });
  }

  Future<void> _onSubmit(Set<String> initialIds) async {
    final studentIds = _picked(initialIds);
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(rosterRepositoryProvider)
          .updateRoster(
            rosterId: widget.roster.id,
            body: {'studentIds': studentIds.toList()},
          );

      await ref
          .read(rosterStudentsProvider(widget.roster.id).notifier)
          .refresh();
      ref
          .read(rosterListControllerProvider.notifier)
          .getAllRosters(forceRefresh: true);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        context.t.error,
        e.userMessage(context.t),
        SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentListControllerProvider);
    final allStudents = studentsState.value ?? const <StudentSummaryResponse>[];
    final rosterStudentsState = ref.watch(
      rosterStudentsProvider(widget.roster.id),
    );
    final rosterStudentIds =
        rosterStudentsState.value?.map((s) => s.id).toSet() ??
        widget.roster.students?.map((s) => s.id).toSet() ??
        const <String>{};

    final pickedIds = _picked(rosterStudentIds);
    final hasChanges = _hasChanges(rosterStudentIds);
    final isLoading =
        studentsState.isLoading ||
        rosterStudentsState.isLoading ||
        _isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.title),
        actions: [
          AssignStudentsButton(
            hasChanges: hasChanges,
            onSubmit: () => _onSubmit(rosterStudentIds),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: Skeletonizer(
        enabled: isLoading,
        ignorePointers: false,
        child: AbsorbPointer(
          absorbing: isLoading,
          child: allStudents.isEmpty && !isLoading
              ? Center(
                  child: Text(
                    context.t.students.filter.empty,
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.builder(
                      itemCount: allStudents.length,
                      itemBuilder: (context, index) {
                        final student = allStudents[index];

                        return StudentCheckboxTile(
                          key: ValueKey(student.id),
                          student: student,
                          selected: pickedIds.contains(student.id),
                          enabled: !isLoading,
                          onToggle: () =>
                              _toggleStudent(rosterStudentIds, student.id),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
