import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

TransactionResponse _income() => TransactionResponse(
  id: 'tx-1',
  amount: 3800,
  date: DateTime(2025, 8, 22),
  type: TransactionType.income,
  createdAt: DateTime(2025, 8, 22, 14, 30),
);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('recent tiles fill the whole card so their ink spans it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RecentTransactions(asyncTransactions: AsyncValue.data([_income()])),
      ),
    );

    final card = tester.getRect(find.byType(RecentTransactions));
    final tile = tester.getRect(find.byType(TransactionTile));
    final avatar = tester.getRect(
      find.descendant(
        of: find.byType(TransactionTile),
        matching: find.byType(Container),
      ),
    );

    expect(tile.left, card.left);
    expect(tile.right, card.right);

    expect(avatar.left - card.left, 20);

    final title = tester.getTopLeft(find.text(t.finance.lastTransactions));

    expect(title.dx, card.left + 20);
  });

  testWidgets(
    'renders add button in right bottom corner and invokes callback',
    (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _wrap(
          RecentTransactions(
            asyncTransactions: AsyncValue.data([_income()]),
            onAddPressed: () => pressed = true,
          ),
        ),
      );

      final card = tester.getRect(find.byType(RecentTransactions));
      final addButton = find.widgetWithText(TextButton, t.add);
      expect(addButton, findsOneWidget);

      final buttonRect = tester.getRect(addButton);
      // Button is near the right edge of the card (offset by 20 padding)
      expect(buttonRect.right, closeTo(card.right - 20, 1.0));
      // Button is at the bottom of the card
      expect(buttonRect.bottom, closeTo(card.bottom - 8, 1.0));

      await tester.tap(addButton);
      await tester.pump();

      expect(pressed, isTrue);
    },
  );

  testWidgets('does not render add button when onAddPressed is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        RecentTransactions(asyncTransactions: AsyncValue.data([_income()])),
      ),
    );

    expect(find.widgetWithText(TextButton, t.add), findsNothing);
  });
}
