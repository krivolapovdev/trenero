// lib/features/finance/utils/transaction_date_formatter.dart
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

  static String formatDateHeader(DateTime txDate, {String? locale}) {
    final resolvedLocale = locale ?? LocaleSettings.currentLocale.languageCode;
    final rawFormatted = DateFormat(
      'd MMMM yyyy, EEE',
      resolvedLocale,
    ).format(txDate);
    final parts = rawFormatted.split(', ');

    if (parts.length == 2 && parts[1].isNotEmpty) {
      final dayOfWeek = parts[1][0].toUpperCase() + parts[1].substring(1);
      return '${parts[0]}, $dayOfWeek';
    }

    return rawFormatted;
  }
}
