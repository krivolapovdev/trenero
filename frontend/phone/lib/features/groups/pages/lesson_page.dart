import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/features/groups/widgets/delete_lesson_bottom_sheet.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

/// Adds a lesson to a group: picks the date and the students that attended.
///
/// When [lesson] is given the page edits the lesson that is already stored on
/// [date]: its attendance is pre-filled and the menu offers deleting it.
class LessonPage extends ConsumerStatefulWidget {
  final String groupId;

  /// The day the lesson is created for / the day [lesson] takes place.
  final DateTime date;

  /// The stored lesson to open. When null a new lesson is created.
  final LessonResponse? lesson;

  const new({
    super.key,
    required this.groupId,
    required this.date,
    this.lesson,
  });

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  static const Duration _animationDuration = Duration(milliseconds: 250);

  late DateTime _selectedDate;

  /// Set once the user picks a student, from then on it wins over the
  /// attendance loaded from the server.
  Set<String>? _pickedStudentIds;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lesson?.date ?? widget.date;
  }

  /// The students that are stored as present for the lesson on the server.
  Set<String> _storedStudentIds(AsyncValue<LessonDetailsResponse>? state) =>
      (state?.value?.studentVisits ?? const <VisitResponse>[])
          .where((visit) => visit.status == VisitStatus.present)
          .map((visit) => visit.studentId)
          .toSet();

  /// A new lesson starts with everybody present, a stored one with the
  /// attendance that was recorded for it, until the user picks a student.
  Set<String> _presentStudentIds(
    List<GroupStudentSummaryResponse> students,
    Set<String> storedStudentIds,
  ) =>
      _pickedStudentIds ??
      (widget.lesson == null
          ? students.map((student) => student.id).toSet()
          : storedStudentIds);

  /// Whether the lesson that is being edited differs from the stored one.
  bool _hasChanges(
    Set<String> presentStudentIds,
    Set<String> storedStudentIds,
  ) {
    final lesson = widget.lesson;

    // A new lesson is always worth saving.
    if (lesson == null) return true;

    final isSameDay =
        DateUtils.dateOnly(_selectedDate) == DateUtils.dateOnly(lesson.date);

    return !isSameDay ||
        presentStudentIds.length != storedStudentIds.length ||
        !presentStudentIds.containsAll(storedStudentIds);
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = DateUtils.dateOnly(_selectedDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(today) ? today : selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked == null || !mounted) return;

    setState(() => _selectedDate = picked);
  }

  void _toggleStudent(Set<String> presentStudentIds, String studentId) =>
      setState(() {
        final next = {...presentStudentIds};

        if (!next.remove(studentId)) next.add(studentId);

        _pickedStudentIds = next;
      });

  void _toggleAll(
    Set<String> presentStudentIds,
    List<GroupStudentSummaryResponse> students,
  ) => setState(() {
    final studentIds = students.map((student) => student.id).toSet();

    _pickedStudentIds = studentIds.every(presentStudentIds.contains)
        ? <String>{}
        : studentIds;
  });

  Future<void> _onSubmit(
    List<GroupStudentSummaryResponse> students,
    Set<String> presentStudentIds,
  ) async {
    FocusScope.of(context).unfocus();

    final lesson = widget.lesson;
    final controller = ref.read(lessonMutationControllerProvider.notifier);

    final isSaved = await (lesson == null
        ? controller.createLesson(
            groupId: widget.groupId,
            date: _selectedDate,
            students: students,
            presentStudentIds: presentStudentIds,
          )
        : controller.updateLesson(
            lessonId: lesson.id,
            groupId: widget.groupId,
            date: _selectedDate,
            students: students,
            presentStudentIds: presentStudentIds,
          ));

    if (!mounted) return;

    if (isSaved) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(lessonMutationControllerProvider).error;

    AppSnackBar.show(
      context,
      error == null ? context.t.error : '${context.t.error}: $error',
      SnackBarType.error,
    );
  }

  Future<void> _onDelete() async {
    final lesson = widget.lesson;
    if (lesson == null) return;

    final isDeleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteLessonBottomSheet(
        lessonId: lesson.id,
        groupId: widget.groupId,
      ),
    );

    if (!mounted || isDeleted != true) return;

    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lesson = widget.lesson;

    final studentsState = ref.watch(groupStudentsProvider(widget.groupId));
    final students =
        studentsState.value ?? const <GroupStudentSummaryResponse>[];
    final detailsState = lesson == null
        ? null
        : ref.watch(lessonDetailsProvider(lesson.id));
    final isLoading = ref.watch(lessonMutationControllerProvider).isLoading;

    final isAttendanceLoading = detailsState?.isLoading ?? false;
    final storedStudentIds = _storedStudentIds(detailsState);
    final presentStudentIds = _presentStudentIds(students, storedStudentIds);
    final hasChanges = _hasChanges(presentStudentIds, storedStudentIds);
    final canEdit = !isLoading && !isAttendanceLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.lessons.groupLesson),
        actions: [
          if (lesson != null)
            PopupMenuButton<String>(
              tooltip: '',
              offset: const Offset(-8, 0),
              color: colorScheme.surface,
              itemBuilder: (menuContext) => [
                PopupMenuItem<String>(
                  onTap: _onDelete,
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _buildDateCard(canEdit),
              _buildStudentCard(
                studentsState: studentsState,
                students: students,
                presentStudentIds: presentStudentIds,
                canEdit: canEdit,
                hasChanges: hasChanges,
                isAttendanceLoading: isAttendanceLoading,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(bool canEdit) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: canEdit ? _pickDate : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.t.lessons.date,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: TextStyle(
            fontSize: 16,
            color: canEdit ? null : Theme.of(context).disabledColor,
          ),
        ),
      ),
    ),
  );

  Widget _buildStudentCard({
    required AsyncValue<List<GroupStudentSummaryResponse>> studentsState,
    required List<GroupStudentSummaryResponse> students,
    required Set<String> presentStudentIds,
    required bool canEdit,
    required bool hasChanges,
    required bool isAttendanceLoading,
    required bool isLoading,
  }) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (students.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: canEdit
                    ? () => _toggleAll(presentStudentIds, students)
                    : null,
                child: Text(
                  students.every(
                        (student) => presentStudentIds.contains(student.id),
                      )
                      ? context.t.lessons.deselectAll
                      : context.t.lessons.selectAll,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _buildStudentList(
              studentsState: studentsState,
              students: students,
              presentStudentIds: presentStudentIds,
              canEdit: canEdit,
              isAttendanceLoading: isAttendanceLoading,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: (isLoading || !hasChanges || students.isEmpty)
                  ? null
                  : () => _onSubmit(students, presentStudentIds),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(widget.lesson == null ? Icons.add : Icons.check),
              label: Text(
                _actionLabel(presentStudentIds, students),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  /// `Create 4/12`: the action of the page together with the number of the
  /// students that attended.
  String _actionLabel(
    Set<String> presentStudentIds,
    List<GroupStudentSummaryResponse> students,
  ) {
    final action = widget.lesson == null ? context.t.create : context.t.update;

    return '$action ${presentStudentIds.length}/${students.length}';
  }

  Widget _buildStudentList({
    required AsyncValue<List<GroupStudentSummaryResponse>> studentsState,
    required List<GroupStudentSummaryResponse> students,
    required Set<String> presentStudentIds,
    required bool canEdit,
    required bool isAttendanceLoading,
  }) {
    if ((studentsState.isLoading || isAttendanceLoading) && students.isEmpty) {
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

    return Column(
      children: students
          .map(
            (student) => _buildStudentTile(
              student: student,
              isPresent: presentStudentIds.contains(student.id),
              canEdit: canEdit,
              presentStudentIds: presentStudentIds,
            ),
          )
          .toList(),
    );
  }

  Widget _buildStudentTile({
    required GroupStudentSummaryResponse student,
    required bool isPresent,
    required bool canEdit,
    required Set<String> presentStudentIds,
  }) => CheckboxListTile(
    value: isPresent,
    onChanged: canEdit
        ? (_) => _toggleStudent(presentStudentIds, student.id)
        : null,
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
}
