import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/i18n/strings.g.dart';

class _Host extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        TextButton(
          onPressed: () =>
              AppSnackBar.show(context, 'page error', SnackBarType.error),
          child: const Text('page failure'),
        ),
        TextButton(
          onPressed: () =>
              AppBottomSheet.show(context: context, child: const _Sheet()),
          child: const Text('open sheet'),
        ),
      ],
    ),
  );
}

class _Sheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: TextButton(
      onPressed: () =>
          AppSnackBar.show(context, 'sheet error', SnackBarType.error),
      child: const Text('sheet failure'),
    ),
  );
}

Widget _host() => TranslationProvider(child: const MaterialApp(home: _Host()));

Future<void> _openSheetAndFail(WidgetTester tester) async {
  await tester.pumpWidget(_host());

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('sheet failure'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _waitForNotification(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('an error outside of a modal is shown by the scaffold', (
    tester,
  ) async {
    await tester.pumpWidget(_host());

    await tester.tap(find.text('page failure'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(AwesomeSnackbarContent), findsOneWidget);

    await _waitForNotification(tester);
  });

  testWidgets('an error of a bottom sheet is shown above the sheet', (
    tester,
  ) async {
    await _openSheetAndFail(tester);

    final notification = find.byType(AwesomeSnackbarContent);

    expect(notification, findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(
      find.descendant(of: find.byType(_Sheet), matching: notification),
      findsNothing,
    );

    expect(
      tester.getBottomLeft(notification).dy,
      lessThan(tester.getTopLeft(find.byType(_Sheet)).dy),
    );

    await _waitForNotification(tester);
  });

  testWidgets('tapping an error above a bottom sheet hides it', (tester) async {
    await _openSheetAndFail(tester);

    await tester.tap(find.byType(AwesomeSnackbarContent));
    await tester.pumpAndSettle();

    expect(find.byType(AwesomeSnackbarContent), findsNothing);
    expect(find.byType(_Sheet), findsOneWidget);

    await _waitForNotification(tester);
  });

  testWidgets('an error above a bottom sheet replaces the previous one', (
    tester,
  ) async {
    await _openSheetAndFail(tester);

    await tester.tap(find.text('sheet failure'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AwesomeSnackbarContent), findsOneWidget);

    await _waitForNotification(tester);
  });
}
