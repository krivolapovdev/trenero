import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/finance/widgets/profit_line_chart.dart';
import 'package:phone/generated/models/payment_metric_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Answers the language provider with a fixed locale.
class _EnglishLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.en;
}

class _RussianLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.ru;
}

Widget _wrap(AppLocale locale, List<PaymentMetricResponse> data) =>
    ProviderScope(
      overrides: [
        languageProvider.overrideWith(
          locale == AppLocale.ru
              ? _RussianLanguageNotifier.new
              : _EnglishLanguageNotifier.new,
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: ProfitLineChart(
              data: data,
              selectedIndex: 0,
              onIndexChanged: (_) {},
            ),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('writes the months in English when the app is in English', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(AppLocale.en, [
        PaymentMetricResponse(date: DateTime(2026, 1, 15), total: 1000),
        PaymentMetricResponse(date: DateTime(2026, 2, 15), total: 2500),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jan'), findsOneWidget);
    expect(find.text('Feb'), findsOneWidget);
    expect(find.text('Янв'), findsNothing);
  });

  testWidgets('writes the months in Russian when the app is in Russian', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(AppLocale.ru, [
        PaymentMetricResponse(date: DateTime(2026, 1, 15), total: 1000),
        PaymentMetricResponse(date: DateTime(2026, 2, 15), total: 2500),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Янв'), findsOneWidget);
    expect(find.text('Февр'), findsOneWidget);
    expect(find.text('Jan'), findsNothing);
  });

  testWidgets('draws nothing without data', (tester) async {
    await tester.pumpWidget(_wrap(AppLocale.en, const []));
    await tester.pumpAndSettle();

    expect(find.byType(ProfitLineChart), findsOneWidget);
    expect(find.text('Jan'), findsNothing);
  });
}
