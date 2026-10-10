import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/widgets/delete_lesson_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/lesson_attendance_bottom_sheet.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

/// Adds a lesson to a group: picks the date and marks every student.
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
  /// The colour the checkbox of a free lesson is filled with.
  static const Color _freeCheckColor = Color(0xFFFFC107);

  late DateTime _selectedDate;

  /// Set once the user changes a mark, from then on it wins over the marks
  /// loaded from the server.
  Map<String, LessonAttendance>? _pickedAttendance;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lesson?.date ?? widget.date;
  }

  /// The marks that are stored for the lesson on the server, keyed by student.
  Map<String, LessonAttendance> _storedAttendance(
    AsyncValue<LessonDetailsResponse>? state,
  ) {
    final visits = state?.value?.studentVisits ?? const <VisitResponse>[];

    return {
      for (final visit in visits)
        visit.studentId: LessonAttendance(
          status: visit.status,
          type: visit.type,
        ),
    };
  }

  /// The mark a student starts with while not loaded from the server: present,
  /// free when the student studies for free.
  LessonAttendance _defaultAttendance(GroupStudentSummaryResponse student) =>
      LessonAttendance(
        status: VisitStatus.present,
        type: student.free ? VisitType.free : VisitType.regular,
      );

  /// A new lesson starts with everybody present, a stored one with the marks
  /// that were recorded for it, until the user changes one.
  Map<String, LessonAttendance> _attendance(
    List<GroupStudentSummaryResponse> students,
    Map<String, LessonAttendance> stored,
  ) {
    final picked = _pickedAttendance;
    if (picked != null) return picked;

    if (widget.lesson != null) return stored;

    return {
      for (final student in students) student.id: _defaultAttendance(student),
    };
  }

  /// The type a mark keeps for [student]: a free student always stores free.
  VisitType _typeFor(
    GroupStudentSummaryResponse student,
    LessonAttendance? current,
  ) => student.free ? VisitType.free : (current?.type ?? VisitType.regular);

  /// Whether the lesson that is being edited differs from the stored one.
  bool _hasChanges(
    Map<String, LessonAttendance> attendance,
    Map<String, LessonAttendance> stored,
  ) {
    final lesson = widget.lesson;

    // A new lesson is always worth saving.
    if (lesson == null) return true;

    final isSameDay =
        DateUtils.dateOnly(_selectedDate) == DateUtils.dateOnly(lesson.date);

    if (!isSameDay) return true;
    if (attendance.length != stored.length) return true;

    return attendance.entries.any((entry) => stored[entry.key] != entry.value);
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

  void _toggleStudent(
    Map<String, LessonAttendance> attendance,
    GroupStudentSummaryResponse student,
  ) => setState(() {
    final next = {...attendance};
    final current = next[student.id];

    next[student.id] = LessonAttendance(
      status: current?.status == VisitStatus.present
          ? VisitStatus.absent
          : VisitStatus.present,
      type: _typeFor(student, current),
    );

    _pickedAttendance = next;
  });

  /// Marks the students of the list present or absent together. A student that
  /// is left unmarked stays unmarked.
  void _toggleAll(
    Map<String, LessonAttendance> attendance,
    List<GroupStudentSummaryResponse> students,
  ) => setState(() {
    final marked = students
        .where((student) => attendance.containsKey(student.id))
        .toList();
    final allPresent =
        marked.isNotEmpty &&
        marked.every(
          (student) => attendance[student.id]?.status == VisitStatus.present,
        );

    final next = {...attendance};
    for (final student in marked) {
      next[student.id] = LessonAttendance(
        status: allPresent ? VisitStatus.absent : VisitStatus.present,
        type: _typeFor(student, next[student.id]),
      );
    }

    _pickedAttendance = next;
  });

  /// Opens the sheet that picks the status and the type of [student]. Leaving
  /// the student unmarked drops their visit.
  Future<void> _editStudent(
    GroupStudentSummaryResponse student,
    Map<String, LessonAttendance> attendance,
  ) async {
    final selection = await AppBottomSheet.show<LessonAttendanceSelection>(
      context: context,
      child: LessonAttendanceBottomSheet(
        studentName: student.fullName,
        free: student.free,
        attendance: attendance[student.id],
      ),
    );

    if (!mounted || selection == null) return;

    setState(() {
      final next = {...attendance};
      final picked = selection.attendance;

      if (picked == null) {
        next.remove(student.id);
      } else {
        next[student.id] = LessonAttendance(
          status: picked.status,
          type: _typeFor(student, picked),
        );
      }

      _pickedAttendance = next;
    });
  }

  Future<void> _onSubmit(
    List<GroupStudentSummaryResponse> students,
    Map<String, LessonAttendance> attendance,
  ) async {
    FocusScope.of(context).unfocus();

    final lesson = widget.lesson;
    final controller = ref.read(lessonMutationControllerProvider.notifier);

    final isSaved = await (lesson == null
        ? controller.createLesson(
            groupId: widget.groupId,
            date: _selectedDate,
            students: students,
            attendance: attendance,
          )
        : controller.updateLesson(
            lessonId: lesson.id,
            groupId: widget.groupId,
            date: _selectedDate,
            students: students,
            attendance: attendance,
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
    final storedAttendance = _storedAttendance(detailsState);
    final attendance = _attendance(students, storedAttendance);
    final hasChanges = _hasChanges(attendance, storedAttendance);
    final canEdit = !isLoading && !isAttendanceLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.lessons.groupLesson),
        actions: [
          _buildSaveAction(
            students: students,
            attendance: attendance,
            hasChanges: hasChanges,
            isLoading: isLoading,
          ),
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
                        context.t.delete,
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
                attendance: attendance,
                canEdit: canEdit,
                isAttendanceLoading: isAttendanceLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The action of the page, living in the app bar: `[4/12]`, the students that
  /// attended over the students of the lesson.
  Widget _buildSaveAction({
    required List<GroupStudentSummaryResponse> students,
    required Map<String, LessonAttendance> attendance,
    required bool hasChanges,
    required bool isLoading,
  }) => TextButton.icon(
    onPressed: (isLoading || !hasChanges || students.isEmpty)
        ? null
        : () => _onSubmit(students, attendance),
    icon: isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(Icons.save),
    label: Text(_actionLabel(attendance, students)),
  );

  String _actionLabel(
    Map<String, LessonAttendance> attendance,
    List<GroupStudentSummaryResponse> students,
  ) {
    final presentCount = students
        .where(
          (student) => attendance[student.id]?.status == VisitStatus.present,
        )
        .length;

    return '[$presentCount/${students.length}]';
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
    required Map<String, LessonAttendance> attendance,
    required bool canEdit,
    required bool isAttendanceLoading,
  }) {
    final markedStudents = students
        .where((student) => attendance.containsKey(student.id))
        .toList();
    final unmarkedStudents = students
        .where((student) => !attendance.containsKey(student.id))
        .toList();
    final isLoading =
        (studentsState.isLoading || isAttendanceLoading) && students.isEmpty;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (students.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  context.t.lessons.noStudents,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else ...[
              if (markedStudents.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: canEdit
                        ? () => _toggleAll(attendance, students)
                        : null,
                    child: Text(
                      _allPresent(markedStudents, attendance)
                          ? context.t.lessons.deselectAll
                          : context.t.lessons.selectAll,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ...markedStudents.indexed.map(
                (entry) => _buildStudentTile(
                  student: entry.$2,
                  number: entry.$1 + 1,
                  attendance: attendance[entry.$2.id],
                  canEdit: canEdit,
                  attendanceMap: attendance,
                ),
              ),
              if (unmarkedStudents.isNotEmpty)
                _buildUnmarkedAccordion(
                  students: unmarkedStudents,
                  firstNumber: markedStudents.length + 1,
                  attendanceMap: attendance,
                  canEdit: canEdit,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Whether every student of [students] is marked present.
  bool _allPresent(
    List<GroupStudentSummaryResponse> students,
    Map<String, LessonAttendance> attendance,
  ) => students.every(
    (student) => attendance[student.id]?.status == VisitStatus.present,
  );

  /// The students of a stored lesson that were never marked: they joined the
  /// group later, so they have no visit for this lesson. They are folded away at
  /// the bottom, drawn struck through and without a checkbox so they cannot be
  /// marked by accident. The ellipsis still lets them be marked on purpose.
  Widget _buildUnmarkedAccordion({
    required List<GroupStudentSummaryResponse> students,
    required int firstNumber,
    required Map<String, LessonAttendance> attendanceMap,
    required bool canEdit,
  }) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        context.t.lessons.notMarked,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      children: students.indexed
          .map(
            (entry) => _buildStudentTile(
              student: entry.$2,
              number: firstNumber + entry.$1,
              attendance: null,
              canEdit: canEdit,
              attendanceMap: attendanceMap,
              unmarked: true,
            ),
          )
          .toList(),
    ),
  );

  /// One student of the lesson.
  ///
  /// The whole row is tappable: tapping it marks the student present when they
  /// were not and absent when they were, a long press opens the sheet that
  /// picks the status and the type. A student that is unmarked has no checkbox
  /// and is only marked on purpose, through the sheet.
  Widget _buildStudentTile({
    required GroupStudentSummaryResponse student,
    required int number,
    required LessonAttendance? attendance,
    required bool canEdit,
    required Map<String, LessonAttendance> attendanceMap,
    bool unmarked = false,
  }) {
    final isFree = attendance?.type == VisitType.free;

    return InkWell(
      onTap: canEdit && !unmarked
          ? () => _toggleStudent(attendanceMap, student)
          : null,
      onLongPress: canEdit ? () => _editStudent(student, attendanceMap) : null,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: SizedBox(
          width: 24,
          child: Text(
            '$number.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            decoration: unmarked ? TextDecoration.lineThrough : null,
            color: unmarked
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: _buildSubtitle(attendance),
        trailing: unmarked
            ? null
            : Checkbox(
                value: attendance?.status == VisitStatus.present,
                activeColor: isFree ? _freeCheckColor : null,
                onChanged: canEdit
                    ? (_) => _toggleStudent(attendanceMap, student)
                    : null,
              ),
      ),
    );
  }

  /// The modifiers of a student, shown small under the name: an excused lesson
  /// and a free lesson are not told by the checkbox alone.
  Widget? _buildSubtitle(LessonAttendance? attendance) {
    final modifiers = <String>[];

    if (attendance?.status == VisitStatus.excused) {
      modifiers.add(context.t.lessons.excused);
    }

    if (attendance?.type == VisitType.free) {
      modifiers.add(context.t.lessons.freeLesson);
    }

    if (modifiers.isEmpty) return null;

    return Text(
      modifiers.join(' · '),
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
