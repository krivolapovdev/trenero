import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/features/students/controllers/student_lesson_mutation_controller.dart';
import 'package:phone/features/students/widgets/delete_student_lesson_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentLessonPage extends ConsumerStatefulWidget {
  final String studentId;

  final String studentName;

  final DateTime date;

  final LessonResponse? lesson;

  const new({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.date,
    this.lesson,
  });

  @override
  ConsumerState<StudentLessonPage> createState() => _StudentLessonPageState();
}

class _StudentLessonPageState extends ConsumerState<StudentLessonPage> {
  late DateTime _selectedDate;

  bool? _pickedIsPresent;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.lesson?.date ?? widget.date;
  }

  bool _storedIsPresent(AsyncValue<LessonDetailsResponse>? state) =>
      (state?.value?.studentVisits ?? const <VisitResponse>[]).any(
        (visit) =>
            visit.studentId == widget.studentId &&
            visit.status == VisitStatus.present,
      );

  bool _isPresent(bool storedIsPresent) =>
      _pickedIsPresent ?? (widget.lesson == null ? true : storedIsPresent);

  bool _hasChanges(bool isPresent, bool storedIsPresent) {
    final lesson = widget.lesson;

    if (lesson == null) return true;

    final isSameDay =
        DateUtils.dateOnly(_selectedDate) == DateUtils.dateOnly(lesson.date);

    return !isSameDay || isPresent != storedIsPresent;
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

  void _togglePresent(bool isPresent) =>
      setState(() => _pickedIsPresent = !isPresent);

  Future<void> _onSubmit(bool isPresent) async {
    FocusScope.of(context).unfocus();

    final lesson = widget.lesson;
    final controller = ref.read(
      studentLessonMutationControllerProvider.notifier,
    );

    final isSaved = await (lesson == null
        ? controller.createStudentLesson(
            studentId: widget.studentId,
            date: _selectedDate,
            isPresent: isPresent,
          )
        : controller.updateStudentLesson(
            lessonId: lesson.id,
            studentId: widget.studentId,
            date: _selectedDate,
            isPresent: isPresent,
          ));

    if (!mounted) return;

    if (isSaved) {
      Navigator.of(context).pop();
      return;
    }

    final error = ref.read(studentLessonMutationControllerProvider).error;

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
    final storedIsPresent = _storedIsPresent(detailsState);
    final isPresent = _isPresent(storedIsPresent);
    final hasChanges = _hasChanges(isPresent, storedIsPresent);
    final canEdit = !isLoading && !isAttendanceLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.lessons.individualLesson),
        actions: [
          if (lesson != null) _IndividualLessonMenu(onDelete: _onDelete),
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
              _StudentLessonDateCard(
                formattedDate: _formatDate(_selectedDate),
                canEdit: canEdit,
                onTap: _pickDate,
              ),
              _StudentAttendanceCard(
                studentName: widget.studentName,
                isPresent: isPresent,
                canEdit: canEdit,
                hasChanges: hasChanges,
                isAttendanceLoading: isAttendanceLoading,
                isLoading: isLoading,
                isUpdate: lesson != null,
                onToggle: () => _togglePresent(isPresent),
                onSubmit: () => _onSubmit(isPresent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndividualLessonMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const new({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-8, 0),
      color: colorScheme.surface,
      itemBuilder: (menuContext) => [
        PopupMenuItem<String>(
          onTap: onDelete,
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
    );
  }
}

class _StudentLessonDateCard extends StatelessWidget {
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
        child: Text(
          formattedDate,
          style: TextStyle(
            fontSize: 16,
            color: canEdit ? null : Theme.of(context).disabledColor,
          ),
        ),
      ),
    ),
  );
}

class _StudentAttendanceCard extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 250);

  final String studentName;
  final bool isPresent;
  final bool canEdit;
  final bool hasChanges;
  final bool isAttendanceLoading;
  final bool isLoading;
  final bool isUpdate;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const new({
    required this.studentName,
    required this.isPresent,
    required this.canEdit,
    required this.hasChanges,
    required this.isAttendanceLoading,
    required this.isLoading,
    required this.isUpdate,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isAttendanceLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : CheckboxListTile(
                    value: isPresent,
                    onChanged: canEdit ? (_) => onToggle() : null,
                    title: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: (isLoading || !hasChanges) ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isUpdate ? Icons.check : Icons.add),
              label: Text(
                isUpdate ? context.t.edit : context.t.create,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
