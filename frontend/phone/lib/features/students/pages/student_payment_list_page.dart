import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentPaymentListPage extends ConsumerWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      studentPaymentsControllerProvider(student.id),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Платежи: ${student.fullName}'), elevation: 0),
      body: paymentsAsync.when(
        data: (transactions) => TransactionListView(
          transactions: transactions,
          overrideTitle: student.fullName,
          emptyText: 'У студента нет платежей',
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
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
