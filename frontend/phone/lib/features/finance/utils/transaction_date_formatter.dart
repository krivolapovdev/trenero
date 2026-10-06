// lib/features/finance/utils/transaction_date_formatter.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

abstract final class TransactionDateFormatter {
  static Map<DateTime, List<TransactionResponse>> groupTransactionsByDate(
    List<TransactionResponse> transactions,
  ) {
    final Map<DateTime, List<TransactionResponse>> grouped = {};

    for (final tx in transactions) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return grouped;
  }

  static String formatDateHeader(DateTime txDate, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (txDate == today) {
      return context.t.today;
    }

    if (txDate == yesterday) {
      return context.t.yesterday;
    }

    final rawFormatted = DateFormat('d MMMM, EEE', 'ru_RU').format(txDate);
    final parts = rawFormatted.split(', ');

    if (parts.length == 2 && parts[1].isNotEmpty) {
      final dayOfWeek = parts[1][0].toUpperCase() + parts[1].substring(1);
      return '${parts[0]}, $dayOfWeek';
    }

    return rawFormatted;
  }
}
