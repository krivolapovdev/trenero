import 'package:intl/intl.dart';

extension AmountFormatting on num {
  String toFormattedAmount({bool showSign = true}) {
    final absAmount = abs();

    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '',
      decimalDigits: absAmount % 1 == 0 ? 0 : 2,
    );

    final formatted = formatter.format(absAmount).trim();

    if (!showSign || this == 0) return formatted;

    final sign = this > 0 ? '+ ' : '– ';
    return '$sign$formatted';
  }
}
