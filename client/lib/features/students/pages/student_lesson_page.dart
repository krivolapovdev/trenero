import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/widgets/lesson_attendance_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_lesson_mutation_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/pages/individual_lesson_menu.dart';
import 'package:phone/features/students/pages/student_lesson_attendance_card.dart';
import 'package:phone/features/students/pages/student_lesson_date_card.dart';
import 'package:phone/features/students/widgets/delete_student_lesson_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentLessonPage extends ConsumerStatefulWidget {
  final String studentId;

  final String studentName;

  final DateTime date;

  final LessonResponse? lesson;

  final bool? free;

  const new({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.date,
    this.lesson,
    this.free,
  });

  @override
  ConsumerState<StudentLessonPage> createState() => _StudentLessonPageState();
}

class _StudentLessonPageState extends ConsumerState<StudentLessonPage> {
  late DateTime _selectedDate;

  LessonAttendance? _pickedAttendance;
  bool _hasPickedAttendance = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lesson?.date ?? widget.date;
  }

  LessonAttendance? _storedAttendance(
    AsyncValue<LessonDetailsResponse>? state,
  ) {
    final visit = (state?.value?.studentVisits ?? const <VisitResponse>[])
        .where((visit) => visit.studentId == widget.studentId)
        .firstOrNull;

    if (visit == null) return null;

    return LessonAttendance(status: visit.status, type: visit.type);
  }

  bool _isStudentFree(AsyncValue<LessonDetailsResponse>? detailsState) {
    if (widget.free != null) return widget.free!;

    final students = ref.watch(studentListControllerProvider).value;
    final student = students
        ?.where((s) => s.id == widget.studentId)
        .firstOrNull;
    if (student != null) return student.free;

    final detailStudent = detailsState?.value?.students
        .where((s) => s.id == widget.studentId)
        .firstOrNull;
    if (detailStudent != null) return detailStudent.free;

    return false;
  }

  LessonAttendance? _attendance(LessonAttendance? stored, bool free) {
    if (_hasPickedAttendance) return _pickedAttendance;

    if (widget.lesson != null) return stored;

    return LessonAttendance(
      status: VisitStatus.present,
      type: free ? VisitType.free : VisitType.regular,
    );
  }

  VisitType _typeFor(bool free, LessonAttendance? current) =>
      free ? VisitType.free : (current?.type ?? VisitType.regular);

  bool _hasChanges(LessonAttendance? attendance, LessonAttendance? stored) {
    final lesson = widget.lesson;

    if (lesson == null) return true;

    final isSameDay =
        DateUtils.dateOnly(_selectedDate) == DateUtils.dateOnly(lesson.date);

    if (!isSameDay) return true;

    return attendance != stored;
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

  void _toggleAttendance(LessonAttendance? current, bool free) {
    setState(() {
      _hasPickedAttendance = true;
      final isPresent = current?.status == VisitStatus.present;
      _pickedAttendance = LessonAttendance(
        status: isPresent ? VisitStatus.absent : VisitStatus.present,
        type: _typeFor(free, current),
      );
    });
  }

  Future<void> _editAttendance(LessonAttendance? current, bool free) async {
    final selection = await AppBottomSheet.show<LessonAttendanceSelection>(
      context: context,
      child: LessonAttendanceBottomSheet(
        studentName: widget.studentName,
        free: free,
        attendance: current,
      ),
    );

    if (!mounted || selection == null) return;

    setState(() {
      _hasPickedAttendance = true;
      final picked = selection.attendance;
      if (picked == null) {
        _pickedAttendance = null;
      } else {
        _pickedAttendance = LessonAttendance(
          status: picked.status,
          type: _typeFor(free, picked),
        );
      }
    });
  }

  Future<void> _onSubmit(LessonAttendance? attendance) async {
    FocusScope.of(context).unfocus();

    final lesson = widget.lesson;
    final controller = ref.read(
      studentLessonMutationControllerProvider.notifier,
    );

    final isSaved = await (lesson == null
        ? controller.createStudentLesson(
            studentId: widget.studentId,
            date: _selectedDate,
            attendance: attendance,
          )
        : controller.updateStudentLesson(
            lessonId: lesson.id,
            studentId: widget.studentId,
            date: _selectedDate,
            attendance: attendance,
          ));

    if (!mounted) return;

    if (isSaved) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(studentLessonMutationControllerProvider).error;

    AppSnackBar.show(
      context,
      context.t.error,
      error?.toString() ?? context.t.error,
      SnackBarType.error,
    );
  }

  Future<void> _onDelete() async {
    final lesson = widget.lesson;
    if (lesson == null) return;

    final isDeleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteStudentLessonBottomSheet(
        lessonId: lesson.id,
        studentId: widget.studentId,
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

    final detailsState = lesson == null
        ? null
        : ref.watch(lessonDetailsProvider(lesson.id));
    final isLoading = ref
        .watch(studentLessonMutationControllerProvider)
        .isLoading;

    final isAttendanceLoading = detailsState?.isLoading ?? false;
    final isFree = _isStudentFree(detailsState);
    final storedAttendance = _storedAttendance(detailsState);
    final attendance = _attendance(storedAttendance, isFree);
    final hasChanges = _hasChanges(attendance, storedAttendance);
    final canEdit = !isLoading && !isAttendanceLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.lessons.individualLesson),
        actions: [
          if (lesson != null) IndividualLessonMenu(onDelete: _onDelete),
          const SizedBox(width: 8),
        ],
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomRounded,
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
              StudentLessonDateCard(
                formattedDate: _formatDate(_selectedDate),
                canEdit: canEdit,
                onTap: _pickDate,
              ),
              StudentLessonAttendanceCard(
                studentName: widget.studentName,
                attendance: attendance,
                canEdit: canEdit,
                hasChanges: hasChanges,
                isAttendanceLoading: isAttendanceLoading,
                isLoading: isLoading,
                isUpdate: lesson != null,
                onToggle: () => _toggleAttendance(attendance, isFree),
                onLongPress: () => _editAttendance(attendance, isFree),
                onSubmit: () => _onSubmit(attendance),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
