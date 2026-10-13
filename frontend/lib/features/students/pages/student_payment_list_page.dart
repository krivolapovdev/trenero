import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/widgets/student_payments_skeleton.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentPaymentListPage extends ConsumerWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      studentPaymentsControllerProvider(student.id),
    );

    Future<void> refreshPayments() => ref
        .read(studentPaymentsControllerProvider(student.id).notifier)
        .refresh();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.students.paymentTitle(name: student.fullName)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.savings_24_regular),
            tooltip: context.t.students.payment,
            onPressed: () => AppBottomSheet.show(
              context: context,
              child: CreateTransactionBottomSheet(
                initialStudentId: student.id,
                initialStudentName: student.fullName,
                initialAmount: student.studentGroups?.firstOrNull?.defaultPrice,
                isIncomeOnly: true,
                isStudentLocked: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: refreshPayments,
        child: paymentsAsync.when(
          data: (transactions) => TransactionListView(
            transactions: transactions,
            overrideTitle: student.fullName,
            emptyText: context.t.students.noPayments,
            onRefresh: refreshPayments,
          ),
          loading: () => StudentPaymentsSkeleton(
            onRefresh: refreshPayments,
            overrideTitle: student.fullName,
            emptyText: context.t.students.noPayments,
          ),
          error: (error, stack) => RetryView(
            message: error.userMessage(context.t),
            messageColor: Theme.of(context).colorScheme.error,
            onRetry: refreshPayments,
          ),
        ),
      ),
    );
  }
}
