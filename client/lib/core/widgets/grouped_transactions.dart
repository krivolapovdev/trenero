import 'package:flutter/material.dart';
import 'package:phone/core/widgets/transaction_date_group.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/generated/models/transaction_response.dart';

class GroupedTransactions extends StatelessWidget {
  final List<TransactionResponse> transactions;
  final String? overrideTitle;
  final bool isTappable;

  const new({
    super.key,
    required this.transactions,
    this.overrideTitle,
    this.isTappable = true,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTransactions =
        TransactionDateFormatter.groupTransactionsByDate(transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groupedTransactions.entries)
          TransactionDateGroup(
            dateHeader: TransactionDateFormatter.formatDateHeader(entry.key),
            transactions: entry.value,
            overrideTitle: overrideTitle,
            isTappable: isTappable,
          ),
      ],
    );
  }
}
