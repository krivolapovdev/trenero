import 'package:intl/intl.dart';

extension NumberExtension on num {
  static const String _currencyLocale = 'ru_RU';

  String toFormattedAmount({bool showSign = true}) {
    final absAmount = abs();

    final formatter = NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '',
      decimalDigits: absAmount % 1 == 0 ? 0 : 2,
    );

    final formatted = formatter.format(absAmount).trim();

    if (!showSign || this == 0) return formatted;

    final sign = this > 0 ? '+ ' : '– ';
    return '$sign$formatted';
  }
}
