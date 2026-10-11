import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/i18n/strings.g.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  final friday = DateTime(2025, 8, 22);

  test('writes the header in Russian for the Russian locale', () {
    expect(
      TransactionDateFormatter.formatDateHeader(friday, locale: 'ru'),
      '22 августа 2025, Пт',
    );
  });

  test('writes the header in English for the English locale', () {
    expect(
      TransactionDateFormatter.formatDateHeader(friday, locale: 'en'),
      '22 August 2025, Fri',
    );
  });

  test('falls back to the current app locale', () async {
    await LocaleSettings.setLocale(AppLocale.en);
    expect(
      TransactionDateFormatter.formatDateHeader(friday),
      '22 August 2025, Fri',
    );

    await LocaleSettings.setLocale(AppLocale.ru);
    expect(
      TransactionDateFormatter.formatDateHeader(friday),
      '22 августа 2025, Пт',
    );
  });
}
