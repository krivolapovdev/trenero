import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionTileInfo {
  static const Color incomeColor = Color(0xFF28A745);
  static const Color expenseColor = Color(0xFFE00153);

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? initials;
  final Color backgroundColor;

  const new({
    required this.title,
    required this.subtitle,
    this.icon,
    this.initials,
    required this.backgroundColor,
  });

  static TransactionTileInfo fromTransaction(
    TransactionResponse transaction, {
    String? overrideTitle,
  }) {
    final details = transaction.paymentDetails;
    final isIncome = transaction.type == TransactionType.income;
    final timeFormatted = DateFormat('HH:mm').format(transaction.createdAt);

    if (details != null) {
      final title = overrideTitle ?? details.studentName ?? t.finance.deposit;
      final paidUntil = details.paidUntil;

      return TransactionTileInfo(
        title: title,
        subtitle: paidUntil != null
            ? '${t.finance.paidUntil} ${DateFormat('dd.MM.yyyy').format(paidUntil)}'
            : timeFormatted,
        initials: title.initials,
        backgroundColor: incomeColor,
      );
    }

    return TransactionTileInfo(
      title: isIncome ? t.finance.deposit : t.finance.withdrawal,
      subtitle: timeFormatted,
      icon: isIncome
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      backgroundColor: isIncome ? incomeColor : expenseColor,
    );
  }
}
