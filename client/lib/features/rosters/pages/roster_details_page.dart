import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/empty_state.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/core/widgets/scrollable_fit.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/controllers/roster_students_controller.dart';
import 'package:phone/features/rosters/widgets/add_roster_students_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/delete_roster_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/edit_roster_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/edit_roster_student_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/roster_student_list_dummy_students.dart';
import 'package:phone/features/rosters/widgets/roster_student_list_view.dart';
import 'package:phone/features/rosters/widgets/roster_student_search_delegate.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RosterDetailsPage extends ConsumerStatefulWidget {
  final RosterResponse roster;

  const new({super.key, required this.roster});

  @override
  ConsumerState<RosterDetailsPage> createState() => _RosterDetailsPageState();
}

class _RosterDetailsPageState extends ConsumerState<RosterDetailsPage> {
  late RosterResponse _roster = widget.roster;

  void _openAddStudents(Set<String> existingIds) {
    AppBottomSheet.show(
      context: context,
      child: AddRosterStudentsBottomSheet(
        rosterId: _roster.id,
        existingStudentIds: existingIds,
      ),
    );
  }

  void _openEditRoster() {
    AppBottomSheet.show(
      context: context,
      child: EditRosterBottomSheet(roster: _roster),
    );
  }

  Future<void> _openEditStudent(
    StudentResponse student,
    List<StudentSummaryResponse> allListedStudents,
  ) async {
    final summary = allListedStudents
        .where((s) => s.id == student.id)
        .firstOrNull;
    await AppBottomSheet.show(
      context: context,
      child: EditRosterStudentBottomSheet(
        rosterId: _roster.id,
        student: student,
        fullSummary: summary,
      ),
    );
  }

  Future<void> _openDeleteRoster() async {
    final deleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteRosterBottomSheet(roster: _roster),
    );

    if (deleted == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rosterListControllerProvider, (previous, next) {
      final updated = (next.value ?? const <RosterResponse>[])
          .where((r) => r.id == _roster.id)
          .firstOrNull;

      if (updated != null && mounted) {
        setState(() => _roster = updated);
      }
    });

    final studentsState = ref.watch(rosterStudentsProvider(_roster.id));
    final allListedStudents =
        ref.watch(studentListControllerProvider).value ??
        const <StudentSummaryResponse>[];

    final students = studentsState.value ?? const <StudentResponse>[];
    final isLoading = studentsState.isLoading;
    final hasError = studentsState.hasError;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _openEditRoster,
          child: Text(_roster.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.search_24_regular),
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            onPressed: students.isEmpty
                ? null
                : () {
                    showSearch(
                      context: context,
                      delegate: RosterStudentSearchDelegate(
                        students,
                        allListedStudents,
                        (studentId) => ref
                            .read(rosterStudentsProvider(_roster.id).notifier)
                            .removeStudent(studentId),
                        '${MaterialLocalizations.of(context).searchFieldLabel}...',
                        onEditStudent: (student) =>
                            _openEditStudent(student, allListedStudents),
                        onLongPressStudent: (student) =>
                            _openEditStudent(student, allListedStudents),
                      ),
                    );
                  },
          ),
          IconButton(
            icon: const Icon(FluentIcons.person_add_24_regular),
            tooltip: context.t.rosters.addStudents,
            onPressed: () =>
                _openAddStudents(students.map((s) => s.id).toSet()),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            color: Theme.of(context).colorScheme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _openEditRoster,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.pencil, size: 20),
                    const SizedBox(width: 12),
                    Text(context.t.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: _openDeleteRoster,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.t.delete,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
        ),
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await ref.read(rosterStudentsProvider(_roster.id).notifier).refresh();
          await ref
              .read(rosterListControllerProvider.notifier)
              .getAllRosters(forceRefresh: true);
        },
        child: hasError && students.isEmpty
            ? RetryView(
                message: studentsState.error.toString(),
                scrollable: true,
                onRetry: () => ref
                    .read(rosterStudentsProvider(_roster.id).notifier)
                    .refresh(),
              )
            : !isLoading && students.isEmpty
            ? ScrollableFit(
                child: EmptyState(
                  buttonText: context.t.rosters.addStudents,
                  subtitle: context.t.rosters.noStudents,
                  onButtonPressed: () => _openAddStudents(const {}),
                ),
              )
            : Skeletonizer(
                enabled: isLoading,
                ignorePointers: false,
                child: RosterStudentListView(
                  students: isLoading && students.isEmpty
                      ? rosterStudentListDummyStudents
                      : students,
                  fullSummaries: allListedStudents,
                  isLoading: isLoading,
                  onEditStudent: (student) =>
                      _openEditStudent(student, allListedStudents),
                  onLongPressStudent: (student) =>
                      _openEditStudent(student, allListedStudents),
                  onDeleteStudent: (studentId) => ref
                      .read(rosterStudentsProvider(_roster.id).notifier)
                      .removeStudent(studentId),
                ),
              ),
      ),
    );
  }
}
