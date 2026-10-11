import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_group_page.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/features/students/widgets/delete_student_bottom_sheet.dart';
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

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);

    final deleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteStudentBottomSheet(student: _student),
    );

    if (!mounted || deleted != true) return;

    navigator.pop();
  }

  Future<void> _refresh() async {
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

      if (!mounted) return;

      final listState = ref.read(studentListControllerProvider);
      if (listState.hasError) return;

      final updated = (listState.value ?? const [])
          .where((student) => student.id == _student.id)
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
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final paymentsAsync = ref.watch(
      studentPaymentsControllerProvider(_student.id),
    );

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
          _StudentAppMenu(
            onEdit: _openEditStudentSheet,
            onCreatePayment: _openCreatePaymentSheet,
            onAssignGroup: _openAssignGroupPage,
            onDelete: _confirmDelete,
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
        onRefresh: _refresh,
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
                child: _StudentHeroCard(
                  student: _student,
                  routeAnimation: routeAnimation,
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

class _StudentHeroCard extends StatelessWidget {
  final StudentSummaryResponse student;
  final Animation<double>? routeAnimation;

  const new({required this.student, this.routeAnimation});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: routeAnimation ?? const AlwaysStoppedAnimation(0),
    builder: (context, child) => HeroMode(
      enabled: routeAnimation?.status != AnimationStatus.reverse,
      child: child!,
    ),
    child: Hero(
      tag: 'student-card-${student.id}',
      child: Material(
        type: MaterialType.transparency,
        child: StudentCard(student: student, onTap: () {}),
      ),
    ),
  );
}

class _StudentAppMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onCreatePayment;
  final VoidCallback onAssignGroup;
  final VoidCallback onDelete;

  const new({
    required this.onEdit,
    required this.onCreatePayment,
    required this.onAssignGroup,
    required this.onDelete,
  });

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
          onTap: onCreatePayment,
          child: Row(
            children: [
              const Icon(FluentIcons.money_24_regular, size: 20),
              const SizedBox(width: 12),
              Text(context.t.students.payment),
            ],
          ),
        ),
        PopupMenuItem<String>(
          onTap: onAssignGroup,
          child: Row(
            children: [
              const Icon(CupertinoIcons.person_2_square_stack, size: 20),
              const SizedBox(width: 12),
              Text(context.t.students.group),
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
