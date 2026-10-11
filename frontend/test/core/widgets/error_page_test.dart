import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/widgets/error_page.dart';
import 'package:phone/i18n/strings.g.dart';

Widget _wrap(Widget child) =>
    TranslationProvider(child: MaterialApp(home: child));

/// The error lottie is rendered at the full width, so a phone shaped viewport
/// is used to keep the whole page on screen.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(960, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

/// The lottie loops, so the page is pumped without `pumpAndSettle`.
Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(_wrap(page));

  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('centers the lottie above the notice and the repeat button', (
    tester,
  ) async {
    _useTallViewport(tester);

    await _pumpPage(tester, const GlobalErrorPage());

    final lottie = find.byType(LottieBuilder);
    final notice = find.text(t.pleaseUpdateApp);
    final button = find.widgetWithText(TextButton, t.repeat);

    expect(lottie, findsOneWidget);
    expect(notice, findsOneWidget);
    expect(button, findsOneWidget);

    // The lottie sits above the notice, which sits above the button.
    expect(
      tester.getBottomLeft(lottie).dy,
      lessThanOrEqualTo(tester.getTopLeft(notice).dy),
    );
    expect(
      tester.getBottomLeft(notice).dy,
      lessThanOrEqualTo(tester.getTopLeft(button).dy),
    );

    // The whole block is centered, so the gaps around it are equal.
    final height = tester.getSize(find.byType(Scaffold)).height;

    expect(
      tester.getTopLeft(lottie).dy,
      closeTo(height - tester.getBottomLeft(button).dy, 0.5),
    );
  });

  testWidgets('the repeat button reports the tap', (tester) async {
    _useTallViewport(tester);

    var repeats = 0;

    await _pumpPage(tester, GlobalErrorPage(onRepeat: () => repeats++));

    await tester.tap(find.widgetWithText(TextButton, t.repeat));
    await tester.pump();

    expect(repeats, 1);
  });

  testWidgets('shows no error text when there is no error', (tester) async {
    _useTallViewport(tester);

    await _pumpPage(tester, const GlobalErrorPage());

    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.text(t.pleaseUpdateApp), findsOneWidget);
    expect(find.text(t.repeat), findsOneWidget);

    // Only the notice and the button label are rendered.
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('shows the small error text below the repeat button', (
    tester,
  ) async {
    _useTallViewport(tester);

    const message = 'Exception: the app is outdated';

    await _pumpPage(tester, const GlobalErrorPage(error: message));

    final error = find.text(message);
    final button = find.widgetWithText(TextButton, t.repeat);

    expect(error, findsOneWidget);

    // It is the small print at the very end of the page.
    expect(tester.widget<Text>(error).style?.fontSize, lessThanOrEqualTo(12));
    expect(
      tester.getTopLeft(error).dy,
      greaterThan(tester.getBottomLeft(button).dy),
    );
  });
}
