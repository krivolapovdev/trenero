import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/i18n/strings.g.dart';

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

/// The text currently held by the field under test.
String _text(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('shows the initial date as dd.MM.yyyy', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DateInputField(
          labelText: 'Date',
          initialDate: DateTime(1999, 12, 31),
          onDateChanged: (_) {},
        ),
      ),
    );

    expect(_text(tester), '31.12.1999');
  });

  testWidgets('inserts the dots while the digits are typed', (tester) async {
    final changed = <DateTime?>[];

    await tester.pumpWidget(
      _wrap(DateInputField(labelText: 'Date', onDateChanged: changed.add)),
    );

    await tester.enterText(find.byType(TextField), '311');
    await tester.pump();
    expect(_text(tester), '31.1');

    await tester.enterText(find.byType(TextField), '31121999');
    await tester.pump();

    expect(_text(tester), '31.12.1999');
    expect(changed.last, DateTime(1999, 12, 31));
  });

  testWidgets('keeps at most the eight digits of a date', (tester) async {
    await tester.pumpWidget(
      _wrap(DateInputField(labelText: 'Date', onDateChanged: (_) {})),
    );

    await tester.enterText(find.byType(TextField), '311219991234');
    await tester.pump();

    expect(_text(tester), '31.12.1999');
  });

  testWidgets('reports null and an error for an impossible date', (
    tester,
  ) async {
    DateTime? changed = DateTime(2020);

    await tester.pumpWidget(
      _wrap(
        DateInputField(
          labelText: 'Date',
          onDateChanged: (date) => changed = date,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '31022020');
    await tester.pump();

    expect(changed, isNull);
    expect(find.text(t.invalidDate), findsOneWidget);
  });

  testWidgets('reports null for a date outside the allowed range', (
    tester,
  ) async {
    DateTime? changed;

    await tester.pumpWidget(
      _wrap(
        DateInputField(
          labelText: 'Date',
          firstDate: DateTime(2020),
          lastDate: DateTime(2021),
          onDateChanged: (date) => changed = date,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '01012021');
    await tester.pump();
    expect(changed, DateTime(2021));

    await tester.enterText(find.byType(TextField), '01012022');
    await tester.pump();
    expect(changed, isNull);
    expect(find.text(t.invalidDate), findsOneWidget);
  });

  testWidgets('the clear button empties the field', (tester) async {
    DateTime? changed = DateTime(2000);

    await tester.pumpWidget(
      _wrap(
        DateInputField(
          labelText: 'Date',
          initialDate: DateTime(1999, 12, 31),
          allowClear: true,
          onDateChanged: (date) => changed = date,
        ),
      ),
    );

    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(_text(tester), isEmpty);
    expect(changed, isNull);
    expect(find.byIcon(Icons.clear), findsNothing);
  });

  testWidgets('follows a new initial date coming from the parent', (
    tester,
  ) async {
    final notifier = ValueNotifier<DateTime?>(DateTime(2020));

    await tester.pumpWidget(
      _wrap(
        ValueListenableBuilder<DateTime?>(
          valueListenable: notifier,
          builder: (context, date, _) => DateInputField(
            labelText: 'Date',
            initialDate: date,
            onDateChanged: (_) {},
          ),
        ),
      ),
    );

    expect(_text(tester), '01.01.2020');

    notifier.value = DateTime(2021, 2, 3);
    await tester.pump();

    expect(_text(tester), '03.02.2021');
  });

  testWidgets('keeps an incomplete value typed by the user', (tester) async {
    final notifier = ValueNotifier<DateTime?>(DateTime(2020));

    await tester.pumpWidget(
      _wrap(
        ValueListenableBuilder<DateTime?>(
          valueListenable: notifier,
          builder: (context, date, _) => DateInputField(
            labelText: 'Date',
            initialDate: date,
            onDateChanged: (value) {
              if (value != null) notifier.value = value;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '9999');
    await tester.pump();

    // The parent keeps its last valid date, the typed text stays untouched.
    expect(notifier.value, DateTime(2020));
    expect(_text(tester), '99.99');
  });

  group('tryParse', () {
    test('reads a complete dd.MM.yyyy value', () {
      expect(DateInputField.tryParse('31.12.1999'), DateTime(1999, 12, 31));
    });

    test('rejects values that are not a real calendar date', () {
      expect(DateInputField.tryParse('31.02.2020'), isNull);
      expect(DateInputField.tryParse('00.01.2020'), isNull);
      expect(DateInputField.tryParse('01.13.2020'), isNull);
      expect(DateInputField.tryParse('01.01.20'), isNull);
      expect(DateInputField.tryParse('1.1.2020'), isNull);
      expect(DateInputField.tryParse(''), isNull);
    });
  });

  group('format', () {
    test('pads the day and the month', () {
      expect(DateInputField.format(DateTime(1999, 12, 31)), '31.12.1999');
      expect(DateInputField.format(DateTime(2000, 1, 5)), '05.01.2000');
    });
  });
}
