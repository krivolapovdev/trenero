import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
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
                initialAmount: student.studentGroup?.defaultPrice,
                isIncomeOnly: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: paymentsAsync.when(
        data: (transactions) => TransactionListView(
          transactions: transactions,
          overrideTitle: student.fullName,
          emptyText: context.t.students.noPayments,
          onRefresh: () async {
            ref.invalidate(studentPaymentsControllerProvider(student.id));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  studentPaymentsControllerProvider(student.id),
                ),
                child: Text(context.t.repeat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
