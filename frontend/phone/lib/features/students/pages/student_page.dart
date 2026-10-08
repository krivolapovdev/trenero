import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/radial_expandable_fab.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/features/students/widgets/edit_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/student_summary_response.dart';
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

    if (!mounted) return;

    final listState = ref.read(studentListControllerProvider);
    final updated = (listState.value ?? const <StudentSummaryResponse>[])
        .where((s) => s.id == _student.id)
        .firstOrNull;

    if (updated != null) setState(() => _student = updated);
  }

  Future<void> _openCreatePaymentSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: CreateTransactionBottomSheet(
        initialStudentId: _student.id,
        initialAmount: _student.studentGroup?.defaultPrice,
        isIncomeOnly: true,
      ),
    );

    if (!mounted) return;

    final listState = ref.read(studentListControllerProvider);
    final updated = (listState.value ?? const <StudentSummaryResponse>[])
        .where((s) => s.id == _student.id)
        .firstOrNull;

    if (updated != null) setState(() => _student = updated);
  }

  @override
  Widget build(BuildContext context) {
    final routeAnimation = ModalRoute.of(context)?.animation;
    final paymentsAsync = ref.watch(
      studentPaymentsControllerProvider(_student.id),
    );

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
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: _openCreatePaymentSheet,
                child: const Row(
                  children: [
                    Icon(Icons.payments, size: 20),
                    SizedBox(width: 12),
                    Text('Payment'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20),
                    SizedBox(width: 12),
                    Text('Lesson'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.inventory, size: 20),
                    SizedBox(width: 12),
                    Text('Archive'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete',
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RadialExpandableFab(
        distance: 120.0,
        children: [
          FloatingActionButton(
            heroTag: 'edit-student',
            onPressed: _openEditStudentSheet,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton(
            heroTag: 'payment-student',
            onPressed: _openCreatePaymentSheet,
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.payments),
          ),
          FloatingActionButton(
            heroTag: 'lesson-student',
            onPressed: () {},
            elevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            child: const Icon(Icons.calendar_month),
          ),
        ],
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
          padding: kRadialFabContentPadding,
          physics: const AlwaysScrollableScrollPhysics(),
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

              StudentLessonsSection(studentId: _student.id),

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
            ],
          ),
        ),
      ),
    );
  }
}
