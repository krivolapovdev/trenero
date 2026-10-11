import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/pages/lesson_date_card.dart';
import 'package:phone/features/groups/pages/lesson_menu.dart';
import 'package:phone/features/groups/pages/save_lesson_action.dart';
import 'package:phone/features/groups/pages/student_attendance_card.dart';
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
            SaveLessonAction(
              isCreate: lesson == null,
              isLoading: isLoading,
              hasChanges: hasChanges,
              studentsAvailable: students.isNotEmpty,
              onPressed: () => _onSubmit(students, attendance),
            ),
          if (lesson != null && !_isEditing)
            LessonMenu(
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
              LessonDateCard(
                formattedDate: _formatDate(_selectedDate),
                canEdit: canEdit,
                onTap: _pickDate,
              ),
              StudentAttendanceCard(
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
