import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/delete_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/edit_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/transaction_popup_menu.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_card.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionPage extends ConsumerStatefulWidget {
  final TransactionResponse transaction;
  final String? overrideTitle;

  const new({super.key, required this.transaction, this.overrideTitle});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  late TransactionResponse _transaction = widget.transaction;

  Future<void> _openEditTransactionSheet() async {
    final updated = await AppBottomSheet.show<TransactionResponse>(
      context: context,
      child: EditTransactionBottomSheet(transaction: _transaction),
    );

    if (!mounted || updated == null) return;

    setState(() {
      _transaction = updated;
    });
  }

  Future<void> _openDeleteTransactionSheet() async {
    final deleted = await AppBottomSheet.show<bool>(
      context: context,
      child: DeleteTransactionBottomSheet(transaction: _transaction),
    );

    if (!mounted || deleted != true) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.finance.transactionTitle),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: [
        TransactionPopupMenu(
          onUpdate: _openEditTransactionSheet,
          onDelete: _openDeleteTransactionSheet,
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: TransactionTicketCard(
        transaction: _transaction,
        overrideTitle: widget.overrideTitle,
      ),
    ),
  );
}
