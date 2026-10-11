import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/finance/controllers/delete_transaction_controller.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks for confirmation before deleting [transaction].
///
/// Pops with `true` when the transaction was deleted.
class DeleteTransactionBottomSheet extends ConsumerWidget {
  final TransactionResponse transaction;

  const new({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.finance.deleteTransaction,
    message: context.t.finance.deleteTransactionMessage,
    delete: () async {
      final controller = deleteTransactionControllerProvider;

      final success = await ref
          .read(controller.notifier)
          .deleteTransaction(transaction.id);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
