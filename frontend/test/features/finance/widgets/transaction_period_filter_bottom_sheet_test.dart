import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/finance/controllers/transaction_filter_controller.dart';
import 'package:phone/features/finance/models/transaction_period_filter.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/features/finance/widgets/transaction_period_filter_bottom_sheet.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeTransactionClient implements TransactionControllerClient {
  @override
  Future<PageTransactionResponse> getPaginatedTransactions({
    int? page = 1,
    int? size = 20,
  }) async => const PageTransactionResponse(content: [], totalElements: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _fieldText(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text;

Future<void> _openSheet(
  WidgetTester tester,
  ProviderContainer container, {
  DateTime? today,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AppBottomSheet.show(
                  context: context,
                  child: TransactionPeriodFilterBottomSheet(
                    today: today ?? DateTime(2026, 10, 15),
                  ),
                ),
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

void main() {
  late ProviderContainer container;

  final septemberPeriod = TransactionPeriodFilter(
    start: DateTime(2026, 9, 16),
    end: DateTime(2026, 10, 13),
  );

  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  setUp(() {
    container = ProviderContainer(
      overrides: [
        transactionServiceProvider.overrideWithValue(_FakeTransactionClient()),
      ],
    );
    addTearDown(container.dispose);
  });

  void seedPeriod() => container
      .read(transactionFilterControllerProvider.notifier)
      .setPeriod(septemberPeriod);

  testWidgets('shows the period fields and the calendar of the saved period', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container);

    expect(find.text(t.finance.filter.title), findsOneWidget);
    expect(find.text(t.finance.filter.apply), findsOneWidget);
    expect(find.text(t.finance.filter.reset), findsOneWidget);
    expect(_fieldText(tester, 0), '16.09.2026');
    expect(_fieldText(tester, 1), '13.10.2026');
    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('centers the title and puts the actions at the bottom', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container);

    final title = tester.widget<Text>(find.text(t.finance.filter.title));
    final reset = tester.getCenter(find.text(t.finance.filter.reset));
    final apply = tester.getCenter(find.text(t.finance.filter.apply));
    final monthHeader = tester.getCenter(find.text('September 2026'));

    expect(title.textAlign, TextAlign.center);
    expect(reset.dx, lessThan(apply.dx));
    expect(reset.dy, greaterThan(monthHeader.dy));
    expect(apply.dy, greaterThan(monthHeader.dy));
  });

  testWidgets('the first calendar tap picks the start and drops the old end', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container);

    expect(_fieldText(tester, 1), '13.10.2026');

    await tester.tap(find.text('20'));
    await tester.pump();

    expect(_fieldText(tester, 0), '20.09.2026');
    expect(_fieldText(tester, 1), isEmpty);
  });

  testWidgets('the second calendar tap picks the end', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('25'));
    await tester.pump();

    expect(_fieldText(tester, 0), '20.09.2026');
    expect(_fieldText(tester, 1), '25.09.2026');
  });

  testWidgets('a tap before the start restarts the range', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('10'));
    await tester.pump();

    expect(_fieldText(tester, 0), '10.09.2026');
    expect(_fieldText(tester, 1), isEmpty);
  });

  testWidgets('a third tap starts a new range instead of adding extra days', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('25'));
    await tester.pump();
    await tester.tap(find.text('28'));
    await tester.pump();

    expect(_fieldText(tester, 0), '28.09.2026');
    expect(_fieldText(tester, 1), isEmpty);
  });

  testWidgets('the calendar follows the focused field', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pump();

    expect(_fieldText(tester, 1), '05.10.2026');
  });

  testWidgets('the month can be changed with the chevrons', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.byIcon(FluentIcons.chevron_left_24_regular));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);

    await tester.tap(find.byIcon(FluentIcons.chevron_right_24_regular));
    await tester.pumpAndSettle();

    expect(find.text('September 2026'), findsOneWidget);
  });

  testWidgets('continue stores the period and closes the sheet', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('25'));
    await tester.pump();

    await tester.tap(find.text(t.finance.filter.apply));
    await tester.pumpAndSettle();

    final period = container.read(transactionFilterControllerProvider);

    expect(period.start, DateTime(2026, 9, 20));
    expect(period.end, DateTime(2026, 9, 25));
    expect(find.byType(TransactionPeriodFilterBottomSheet), findsNothing);
  });

  testWidgets('emptying the fields clears the period', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.enterText(find.byType(TextField).at(1), '');
    await tester.pump();

    await tester.tap(find.text(t.finance.filter.apply));
    await tester.pumpAndSettle();

    expect(container.read(transactionFilterControllerProvider).isEmpty, isTrue);
  });

  testWidgets('reset clears the period and closes the sheet', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.tap(find.text(t.finance.filter.reset));
    await tester.pumpAndSettle();

    expect(container.read(transactionFilterControllerProvider).isEmpty, isTrue);
    expect(find.byType(TransactionPeriodFilterBottomSheet), findsNothing);
  });

  testWidgets('an inverted period cannot be saved', (tester) async {
    seedPeriod();

    await _openSheet(tester, container);

    await tester.enterText(find.byType(TextField).at(0), '20102026');
    await tester.pump();

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, t.finance.filter.apply),
    );

    expect(button.onPressed, isNull);

    await tester.tap(find.text(t.finance.filter.apply));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionPeriodFilterBottomSheet), findsOneWidget);
    expect(
      container.read(transactionFilterControllerProvider).start,
      DateTime(2026, 9, 16),
    );
  });

  testWidgets('cannot select future days from calendar but can select today', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container, today: DateTime(2026, 10, 15));

    // Focus end field to show October 2026
    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);

    // Tapping on day 16 (tomorrow) should not select it
    await tester.tap(find.text('16'));
    await tester.pump();

    expect(_fieldText(tester, 1), '13.10.2026');

    // Tapping on day 15 (today) should select it
    await tester.tap(find.text('15'));
    await tester.pump();

    expect(_fieldText(tester, 1), '15.10.2026');
  });

  testWidgets('cannot navigate past the current month', (tester) async {
    seedPeriod();

    await _openSheet(tester, container, today: DateTime(2026, 10, 15));

    // Focus end field to show October 2026
    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);

    final nextButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, FluentIcons.chevron_right_24_regular),
    );
    expect(nextButton.onPressed, isNull);
  });

  testWidgets('a future date typed manually into start or end field shows error and disables apply', (
    tester,
  ) async {
    seedPeriod();

    await _openSheet(tester, container, today: DateTime(2026, 10, 15));

    expect(find.text(t.invalidDate), findsNothing);

    // Type tomorrow's date into end field
    await tester.enterText(find.byType(TextField).at(1), '16102026');
    await tester.pump();

    expect(find.text(t.invalidDate), findsOneWidget);

    var button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, t.finance.filter.apply),
    );
    expect(button.onPressed, isNull);

    // Clear end and type tomorrow's date into start field
    await tester.enterText(find.byType(TextField).at(1), '');
    await tester.enterText(find.byType(TextField).at(0), '16102026');
    await tester.pump();

    expect(find.text(t.invalidDate), findsOneWidget);

    button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, t.finance.filter.apply),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text(t.finance.filter.apply));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionPeriodFilterBottomSheet), findsOneWidget);

    // Enter valid date (today)
    await tester.enterText(find.byType(TextField).at(0), '15102026');
    await tester.pump();

    expect(find.text(t.invalidDate), findsNothing);
  });
}
