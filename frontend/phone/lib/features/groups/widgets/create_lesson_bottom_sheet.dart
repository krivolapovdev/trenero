import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/create_lesson_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Adds a lesson to a group: picks the date and the students that attended.
///
/// The picked students are marked as present, the rest of the group is sent
/// along by the backend as unmarked visits.
class CreateLessonBottomSheet extends ConsumerStatefulWidget {
  final String groupId;

  const new({super.key, required this.groupId});

  @override
  ConsumerState<CreateLessonBottomSheet> createState() =>
      _CreateLessonBottomSheetState();
}

class _CreateLessonBottomSheetState
    extends ConsumerState<CreateLessonBottomSheet> {
  static const Duration _animationDuration = Duration(milliseconds: 250);

  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedStudentIds = {};

  bool _areAllSelected(List<GroupStudentSummaryResponse> students) =>
      students.isNotEmpty &&
      students.every((student) => _selectedStudentIds.contains(student.id));

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );

    if (picked == null || !mounted) return;

    setState(() => _selectedDate = picked);
  }

  void _toggleStudent(String studentId) => setState(() {
    if (!_selectedStudentIds.remove(studentId)) {
      _selectedStudentIds.add(studentId);
    }
  });

  /// Selects everybody when at least one student is missing, clears otherwise.
  void _toggleAll(List<GroupStudentSummaryResponse> students) => setState(() {
    if (_areAllSelected(students)) {
      _selectedStudentIds.removeAll(students.map((student) => student.id));
    } else {
      _selectedStudentIds.addAll(students.map((student) => student.id));
    }
  });

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();

    final isSaved = await ref
        .read(createLessonControllerProvider.notifier)
        .saveLesson(
          groupId: widget.groupId,
          date: _selectedDate,
          studentIds: _selectedStudentIds,
        );

    if (!mounted) return;

    if (isSaved) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(createLessonControllerProvider).error;

    AppSnackBar.show(
      context,
      error == null ? context.t.error : '${context.t.error}: $error',
      SnackBarType.error,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(groupStudentsProvider(widget.groupId));
    final students =
        studentsState.value ?? const <GroupStudentSummaryResponse>[];
    final isLoading = ref.watch(createLessonControllerProvider).isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22, top: 0, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.lessons.createLesson,
              style: const TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 22,
                    children: [
                      _buildDateField(isLoading),
                      _buildStudentPicker(studentsState, students),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            _buildBottomBar(students, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(bool isLoading) => SizedBox(
    width: double.infinity,
    child: InkWell(
      onTap: isLoading ? null : _pickDate,
      borderRadius: BorderRadius.circular(20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.t.lessons.date,
          enabled: !isLoading,
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: TextStyle(
            fontSize: 16,
            color: isLoading ? Theme.of(context).disabledColor : null,
          ),
        ),
      ),
    ),
  );

  Widget _buildStudentPicker(
    AsyncValue<List<GroupStudentSummaryResponse>> studentsState,
    List<GroupStudentSummaryResponse> students,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AnimatedSize(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: _buildStudentList(studentsState, students),
      ),
    ],
  );

  Widget _buildStudentList(
    AsyncValue<List<GroupStudentSummaryResponse>> studentsState,
    List<GroupStudentSummaryResponse> students,
  ) {
    if (studentsState.isLoading && students.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          context.t.lessons.noStudents,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(children: students.map(_buildStudentTile).toList());
  }

  Widget _buildStudentTile(GroupStudentSummaryResponse student) =>
      CheckboxListTile(
        value: _selectedStudentIds.contains(student.id),
        onChanged: (_) => _toggleStudent(student.id),
        title: Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: EdgeInsets.zero,
        dense: true,
      );

  /// How many students are picked, followed by the save action.
  Widget _buildBottomBar(
    List<GroupStudentSummaryResponse> students,
    bool isLoading,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (students.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _toggleAll(students),
              child: Text(
                _areAllSelected(students)
                    ? context.t.lessons.deselectAll
                    : context.t.lessons.selectAll,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

        const Spacer(),

        TextButton.icon(
          onPressed: (isLoading || students.isEmpty) ? null : _onSubmit,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(
            '${context.t.create} [${_selectedStudentIds.length}/${students.length}]',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
