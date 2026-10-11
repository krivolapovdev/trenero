import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_group_page.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/features/students/widgets/edit_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/features/students/widgets/student_groups_section.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentPage extends ConsumerStatefulWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  ConsumerState<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends ConsumerState<StudentPage> {
  late StudentSummaryResponse _student = widget.student;
  bool _isRefreshing = false;

  Future<void> _openEditStudentSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: EditStudentBottomSheet(student: _student),
    );
  }

  /// Opens the group page of the student; the card and the lessons follow the
  /// reloaded student list.
  Future<void> _openAssignGroupPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentGroupPage(
          studentId: _student.id,
          initialGroupIds: _studentGroupIds,
        ),
      ),
    );
  }

  /// The ids of every group the student belongs to, used to preselect them on
  /// the group page.
  Set<String> get _studentGroupIds {
    final groups = _student.studentGroups;

    if (groups != null && groups.isNotEmpty) {
      return groups.map((group) => group.id).toSet();
    }

    final group = _student.studentGroup;
    return group == null ? const <String>{} : {group.id};
  }

  Future<void> _openCreatePaymentSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: CreateTransactionBottomSheet(
        initialStudentId: _student.id,
        initialStudentName: _student.fullName,
        initialAmount: _student.studentGroup?.defaultPrice,
        isIncomeOnly: true,
        isStudentLocked: true,
      ),
    );
  }

  /// Opens the lesson page for a new individual lesson of the student.
  Future<void> _openCreateLessonPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLessonPage(
          studentId: _student.id,
          studentName: _student.fullName,
          date: DateUtils.dateOnly(DateTime.now()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final paymentsAsync = ref.watch(
      studentPaymentsControllerProvider(_student.id),
    );

    // The student list is reloaded in the background after a payment, a lesson
    // or a group change; keep the card and the lessons in sync with it.
    ref.listen(studentListControllerProvider, (previous, next) {
      final updated = (next.value ?? const <StudentSummaryResponse>[])
          .where((student) => student.id == _student.id)
          .firstOrNull;

      if (updated != null) {
        setState(() => _student = updated);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_student.fullName),
        actions: [
          PopupMenuButton<String>(
            tooltip: '',
            offset: const Offset(-8, 0),
            color: Theme.of(context).colorScheme.surface,
            itemBuilder: (menuContext) => [
              PopupMenuItem<String>(
                onTap: _openEditStudentSheet,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.text_cursor, size: 20),
                    const SizedBox(width: 12),
                    Text(context.t.edit),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: _openCreatePaymentSheet,
                child: Row(
                  children: [
                    const Icon(FluentIcons.money_24_regular, size: 20),
                    const SizedBox(width: 12),
                    Text(context.t.students.payment),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: _openAssignGroupPage,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.person_2_square_stack, size: 20),
                    const SizedBox(width: 12),
                    Text(context.t.students.group),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: _openCreateLessonPage,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.calendar, size: 20),
                    const SizedBox(width: 12),
                    Text(context.t.lessons.title),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {},
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
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          setState(() => _isRefreshing = true);

          try {
            await Future.wait([
              ref.read(studentLessonsProvider(_student.id).notifier).refresh(),
              ref
                  .read(studentPaymentsControllerProvider(_student.id).notifier)
                  .refresh(),
              ref
                  .read(studentListControllerProvider.notifier)
                  .getAllStudents(forceRefresh: true),
            ]);

            if (!context.mounted) return;

            final listState = ref.read(studentListControllerProvider);
            if (listState.hasError) return;

            final updated = (listState.value ?? const [])
                .where((s) => s.id == _student.id)
                .firstOrNull;

            if (updated == null) {
              Navigator.of(context).pop();
              return;
            }

            setState(() => _student = updated);
          } finally {
            if (mounted) {
              setState(() => _isRefreshing = false);
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            spacing: 16,
            children: [
              Skeletonizer(
                enabled: _isRefreshing,
                ignorePointers: false,
                child: AnimatedBuilder(
                  animation: routeAnimation ?? const AlwaysStoppedAnimation(0),
                  builder: (context, child) => HeroMode(
                    enabled: routeAnimation?.status != AnimationStatus.reverse,
                    child: child!,
                  ),
                  child: Hero(
                    tag: 'student-card-${_student.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: StudentCard(student: _student, onTap: () {}),
                    ),
                  ),
                ),
              ),

              StudentLessonsSection(
                studentId: _student.id,
                studentName: _student.fullName,
                studentGroup: _student.studentGroup,
              ),

              RecentTransactions(
                asyncTransactions: paymentsAsync,
                overrideTitle: _student.fullName,
                onSeeAllPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentPaymentListPage(student: _student),
                    ),
                  );
                },
              ),

              StudentGroupsSection(
                student: _student,
                onEdit: _openAssignGroupPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
