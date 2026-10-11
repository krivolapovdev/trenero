import 'package:flutter/cupertino.dart';
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
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

const Color _freeCheckColor = Color(0xFFFFC107);

class LessonPage extends ConsumerStatefulWidget {
  final String groupId;

  final DateTime date;

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
  late DateTime _selectedDate;

  Map<String, LessonAttendance>? _pickedAttendance;

  late bool _isEditing = widget.lesson == null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lesson?.date ?? widget.date;
  }

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

  LessonAttendance _defaultAttendance(GroupStudentSummaryResponse student) =>
      LessonAttendance(
        status: VisitStatus.present,
        type: student.free ? VisitType.free : VisitType.regular,
      );

  List<GroupStudentSummaryResponse> _lessonStudents(
    List<GroupStudentSummaryResponse> groupStudents,
    List<StudentResponse> visitStudents,
  ) {
    final groupStudentIds = groupStudents.map((student) => student.id).toSet();

    return [
      ...groupStudents,
      ...visitStudents
          .where((student) => !groupStudentIds.contains(student.id))
          .map(_toGroupStudent),
    ];
  }

  GroupStudentSummaryResponse _toGroupStudent(StudentResponse student) =>
      GroupStudentSummaryResponse(
        id: student.id,
        fullName: student.fullName,
        birthdate: student.birthdate,
        phone: student.phone,
        note: student.note,
        createdAt: student.createdAt,
        free: student.free,
        statuses: const [],
      );

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

  VisitType _typeFor(
    GroupStudentSummaryResponse student,
    LessonAttendance? current,
  ) => student.free ? VisitType.free : (current?.type ?? VisitType.regular);

  bool _hasChanges(
    Map<String, LessonAttendance> attendance,
    Map<String, LessonAttendance> stored,
  ) {
    final lesson = widget.lesson;

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
    final detailsState = lesson == null
        ? null
        : ref.watch(lessonDetailsProvider(lesson.id));
    final isLoading = ref.watch(lessonMutationControllerProvider).isLoading;

    final students = _lessonStudents(
      studentsState.value ?? const <GroupStudentSummaryResponse>[],
      detailsState?.value?.students ?? const <StudentResponse>[],
    );
    final isAttendanceLoading = detailsState?.isLoading ?? false;
    final storedAttendance = _storedAttendance(detailsState);
    final attendance = _attendance(students, storedAttendance);
    final hasChanges = _hasChanges(attendance, storedAttendance);
    final canEdit = _isEditing && !isLoading && !isAttendanceLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.lessons.groupLesson),
        actions: [
          if (lesson == null || _isEditing)
            _SaveLessonAction(
              isCreate: lesson == null,
              isLoading: isLoading,
              hasChanges: hasChanges,
              studentsAvailable: students.isNotEmpty,
              onPressed: () => _onSubmit(students, attendance),
            ),
          if (lesson != null && !_isEditing)
            _LessonMenu(
              onEdit: () => setState(() => _isEditing = true),
              onDelete: _onDelete,
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
              _LessonDateCard(
                formattedDate: _formatDate(_selectedDate),
                canEdit: canEdit,
                onTap: _pickDate,
              ),
              _StudentAttendanceCard(
                students: students,
                attendance: attendance,
                canEdit: canEdit,
                isAttendanceLoading: isAttendanceLoading,
                isLoading: isLoading,
                onToggle: (student) => _toggleStudent(attendance, student),
                onLongPress: (student) => _editStudent(student, attendance),
                onToggleAll: () => _toggleAll(attendance, students),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveLessonAction extends StatelessWidget {
  final bool isCreate;
  final bool isLoading;
  final bool hasChanges;
  final bool studentsAvailable;
  final VoidCallback onPressed;

  const new({
    required this.isCreate,
    required this.isLoading,
    required this.hasChanges,
    required this.studentsAvailable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: (isLoading || !hasChanges || !studentsAvailable)
        ? null
        : onPressed,
    icon: isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(
      isCreate ? context.t.create : context.t.update,
      style: const TextStyle(fontSize: 18),
    ),
  );
}

class _LessonMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const new({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-8, 0),
      color: Theme.of(context).colorScheme.surface,
      itemBuilder: (menuContext) => [
        PopupMenuItem<String>(
          onTap: onEdit,
          child: Row(
            children: [
              const Icon(CupertinoIcons.text_cursor, size: 20),
              const SizedBox(width: 12),
              Text(context.t.edit),
            ],
          ),
        ),
        PopupMenuItem<String>(
          onTap: onDelete,
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, size: 20, color: errorColor),
              const SizedBox(width: 12),
              Text(context.t.delete, style: TextStyle(color: errorColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LessonDateCard extends StatelessWidget {
  final String formattedDate;
  final bool canEdit;
  final VoidCallback onTap;

  const new({
    required this.formattedDate,
    required this.canEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: canEdit ? onTap : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.t.lessons.date,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        ),
        child: Text(formattedDate, style: const TextStyle(fontSize: 16)),
      ),
    ),
  );
}

class _StudentAttendanceCard extends StatelessWidget {
  static const double _cornerRadius = 16;

  final List<GroupStudentSummaryResponse> students;
  final Map<String, LessonAttendance> attendance;
  final bool canEdit;
  final bool isAttendanceLoading;
  final bool isLoading;
  final ValueChanged<GroupStudentSummaryResponse> onToggle;
  final ValueChanged<GroupStudentSummaryResponse> onLongPress;
  final VoidCallback onToggleAll;

  const new({
    required this.students,
    required this.attendance,
    required this.canEdit,
    required this.isAttendanceLoading,
    required this.isLoading,
    required this.onToggle,
    required this.onLongPress,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final markedStudents = students
        .where((student) => attendance.containsKey(student.id))
        .toList();
    final unmarkedStudents = students
        .where((student) => !attendance.containsKey(student.id))
        .toList();
    final isStudentsLoading =
        (isLoading || isAttendanceLoading) && students.isEmpty;
    final allPresent =
        markedStudents.isNotEmpty &&
        markedStudents.every(
          (student) => attendance[student.id]?.status == VisitStatus.present,
        );

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isStudentsLoading)
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
              if (canEdit && markedStudents.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onToggleAll,
                    child: Text(
                      allPresent
                          ? context.t.lessons.deselectAll
                          : context.t.lessons.selectAll,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              for (final (index, student) in markedStudents.indexed)
                _StudentAttendanceTile(
                  key: ValueKey(student.id),
                  student: student,
                  number: index + 1,
                  attendance: attendance[student.id],
                  canEdit: canEdit,
                  onToggle: () => onToggle(student),
                  onLongPress: () => onLongPress(student),
                ),
              if (unmarkedStudents.isNotEmpty)
                _UnmarkedStudentsAccordion(
                  students: unmarkedStudents,
                  firstNumber: markedStudents.length + 1,
                  canEdit: canEdit,
                  onToggle: onToggle,
                  onLongPress: onLongPress,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnmarkedStudentsAccordion extends StatelessWidget {
  final List<GroupStudentSummaryResponse> students;
  final int firstNumber;
  final bool canEdit;
  final ValueChanged<GroupStudentSummaryResponse> onToggle;
  final ValueChanged<GroupStudentSummaryResponse> onLongPress;

  const new({
    required this.students,
    required this.firstNumber,
    required this.canEdit,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        context.t.lessons.notMarked,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      children: [
        for (final (index, student) in students.indexed)
          _StudentAttendanceTile(
            key: ValueKey(student.id),
            student: student,
            number: firstNumber + index,
            canEdit: canEdit,
            unmarked: true,
            onToggle: () => onToggle(student),
            onLongPress: () => onLongPress(student),
          ),
      ],
    ),
  );
}

class _StudentAttendanceTile extends StatelessWidget {
  final GroupStudentSummaryResponse student;
  final int number;
  final LessonAttendance? attendance;
  final bool canEdit;
  final bool unmarked;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  const new({
    super.key,
    required this.student,
    required this.number,
    required this.canEdit,
    required this.onToggle,
    required this.onLongPress,
    this.attendance,
    this.unmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFree = attendance?.type == VisitType.free;
    final isPresent = attendance?.status == VisitStatus.present;

    final modifiers = <String>[
      if (attendance?.status == VisitStatus.excused) context.t.lessons.excused,
      if (attendance?.type == VisitType.free) context.t.lessons.freeLesson,
    ];

    return InkWell(
      onTap: canEdit && !unmarked ? onToggle : null,
      onLongPress: canEdit ? onLongPress : null,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: SizedBox(
          width: 24,
          child: Text(
            '$number.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
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
            color: unmarked ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: modifiers.isEmpty
            ? null
            : _ModifiersText(modifiers: modifiers),
        trailing: unmarked
            ? null
            : canEdit
            ? Checkbox(
                value: isPresent,
                activeColor: isFree ? _freeCheckColor : null,
                onChanged: (_) => onToggle(),
              )
            : _AttendanceMark(
                isPresent: isPresent,
                isFree: isFree,
                status: attendance?.status,
              ),
      ),
    );
  }
}

class _ModifiersText extends StatelessWidget {
  final List<String> modifiers;

  const new({required this.modifiers});

  @override
  Widget build(BuildContext context) => Text(
    modifiers.join(' · '),
    style: TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _AttendanceMark extends StatelessWidget {
  static const double _size = 48;
  static const double _iconSize = 24;

  final bool isPresent;
  final bool isFree;
  final VisitStatus? status;

  const new({required this.isPresent, required this.isFree, this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final label = switch (status) {
      VisitStatus.present => context.t.lessons.present,
      VisitStatus.excused => context.t.lessons.excused,
      _ => context.t.lessons.absent,
    };

    return Semantics(
      label: label,
      child: SizedBox.square(
        dimension: _size,
        child: Icon(
          isPresent ? Icons.check_box : Icons.check_box_outline_blank,
          size: _iconSize,
          color: isPresent
              ? (isFree ? _freeCheckColor : colorScheme.primary)
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
