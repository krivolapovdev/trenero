import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_app_menu.dart';
import 'package:phone/features/students/pages/student_group_page.dart';
import 'package:phone/features/students/pages/student_lesson_page.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/features/students/widgets/delete_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/edit_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_groups_section.dart';
import 'package:phone/features/students/widgets/student_header.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/features/students/widgets/student_report_bottom_sheet.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentPage extends ConsumerStatefulWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  ConsumerState<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends ConsumerState<StudentPage> {
  late StudentSummaryResponse _student = widget.student;
  late final ScrollController _scrollController = ScrollController();
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _openCreateLessonPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentLessonPage(
          studentId: _student.id,
          studentName: _student.fullName,
          free: _student.free,
          date: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _openReportSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: StudentReportBottomSheet(student: _student),
    );
  }

  Set<String> get _studentGroupIds =>
      (_student.studentGroups ?? const []).map((group) => group.id).toSet();

  Future<void> _openCreatePaymentSheet() async {
    await AppBottomSheet.show(
      context: context,
      child: CreateTransactionBottomSheet(
        initialStudentId: _student.id,
        initialStudentName: _student.fullName,
        initialAmount: _student.studentGroups?.firstOrNull?.defaultPrice,
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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction != ScrollDirection.idle) {
        _lastScrollDirection = notification.direction;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _snapIfNeeded();
        });
      }
    } else if (notification is ScrollEndNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _snapIfNeeded();
      });
    }
    return false;
  }

  void _snapIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;

    // Do not snap if overscrolling (pull-to-refresh)
    if (position.outOfRange) return;

    final offset = position.pixels;
    const snapOffset = StudentHeaderDelegate.contentHeight;

    if (offset > 1.0 && offset < snapOffset - 1.0) {
      final double target;
      if (_lastScrollDirection == ScrollDirection.reverse && offset > 20.0) {
        target = snapOffset;
      } else if (_lastScrollDirection == ScrollDirection.forward &&
          offset < snapOffset - 20.0) {
        target = 0.0;
      } else {
        target = offset < (snapOffset / 2) ? 0.0 : snapOffset;
      }

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final topPadding = MediaQuery.paddingOf(context).top;
    final headerMaxHeight =
        topPadding + kToolbarHeight + StudentHeaderDelegate.contentHeight;

    const overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: CustomMaterialIndicator(
          edgeOffset: headerMaxHeight,
          displacement: 20,
          color: Colors.black,
          clipBehavior: Clip.antiAlias,
          onRefresh: _refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              controller: _scrollController,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StudentHeaderDelegate(
                    student: _student,
                    topPadding: topPadding,
                    isRefreshing: _isRefreshing,
                    menu: StudentAppMenu(
                      onEdit: _openEditStudentSheet,
                      onCreateLesson: _openCreateLessonPage,
                      onCreatePayment: _openCreatePaymentSheet,
                      onAssignGroup: _openAssignGroupPage,
                      onReport: _openReportSheet,
                      onDelete: _confirmDelete,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.list(
                    children: [
                      StudentLessonsSection(
                        studentId: _student.id,
                        studentName: _student.fullName,
                        studentGroups: _student.studentGroups ?? const [],
                      ),
                      const SizedBox(height: 16),
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
                        onAddPressed: _openCreatePaymentSheet,
                      ),
                      const SizedBox(height: 16),
                      StudentGroupsSection(
                        student: _student,
                        onEdit: _openAssignGroupPage,
                      ),
                    ],
                  ),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(
                    height: StudentHeaderDelegate.contentHeight + 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
