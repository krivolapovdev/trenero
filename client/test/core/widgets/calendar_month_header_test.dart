import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/calendar_month_header.dart';

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('writes the shown month and year before the arrows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthHeader(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      ),
    );

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.byIcon(FluentIcons.chevron_left_24_regular), findsOneWidget);
    expect(find.byIcon(FluentIcons.chevron_right_24_regular), findsOneWidget);
  });

  testWidgets('each arrow steps a month', (tester) async {
    var previous = 0;
    var next = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthHeader(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
            onPreviousMonth: () => previous++,
            onNextMonth: () => next++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(FluentIcons.chevron_left_24_regular));
    await tester.tap(find.byIcon(FluentIcons.chevron_right_24_regular));
    await tester.pump();

    expect(previous, 1);
    expect(next, 1);
  });

  testWidgets('an arrow without a callback is disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CalendarMonthHeader(
            focusedDay: DateTime(2026, 10, 8),
            locale: 'en',
          ),
        ),
      ),
    );

    IconButton arrowOf(IconData icon) => tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)),
    );

    expect(arrowOf(FluentIcons.chevron_left_24_regular).onPressed, isNull);
    expect(arrowOf(FluentIcons.chevron_right_24_regular).onPressed, isNull);
  });
}
