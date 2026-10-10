import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/calendar_month_navigator.dart';

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('writes the shown month and year between the arrows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthNavigator(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      ),
    );

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('each arrow steps a month', (tester) async {
    var previous = 0;
    var next = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthNavigator(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
            onPreviousMonth: () => previous++,
            onNextMonth: () => next++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(previous, 1);
    expect(next, 1);
  });

  testWidgets('an arrow without a callback is disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthNavigator(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
          ),
        ),
      ),
    );

    IconButton arrowOf(IconData icon) => tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)),
    );

    expect(arrowOf(Icons.chevron_left).onPressed, isNull);
    expect(arrowOf(Icons.chevron_right).onPressed, isNull);
  });
}
