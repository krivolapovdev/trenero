import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_card.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionPage extends StatelessWidget {
  final TransactionResponse transaction;
  final String? overrideTitle;

  const new({super.key, required this.transaction, this.overrideTitle});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.finance.transactionTitle),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: TransactionTicketCard(
        transaction: transaction,
        overrideTitle: overrideTitle,
      ),
    ),
  );
}
