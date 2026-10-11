import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionTileInfo {
  static const Color incomeColor = Color(0xFF28A745);
  static const Color expenseColor = Color(0xFFE00153);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;

  const new({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
  });

  static TransactionTileInfo fromTransaction(
    TransactionResponse transaction, {
    String? overrideTitle,
  }) {
    final details = transaction.paymentDetails;
    final isIncome = transaction.type == TransactionType.income;
    final typeIcon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final typeColor = isIncome ? incomeColor : expenseColor;

    if (details != null) {
      final title = overrideTitle ?? details.studentName ?? t.finance.deposit;
      final paidUntil = details.paidUntil;

      return TransactionTileInfo(
        title: title,
        subtitle: paidUntil != null
            ? '${t.finance.paidUntil} ${DateFormat('dd.MM.yyyy').format(paidUntil)}'
            : '',
        icon: typeIcon,
        backgroundColor: typeColor,
      );
    }

    return TransactionTileInfo(
      title: isIncome ? t.finance.deposit : t.finance.withdrawal,
      subtitle: '',
      icon: typeIcon,
      backgroundColor: typeColor,
    );
  }
}
