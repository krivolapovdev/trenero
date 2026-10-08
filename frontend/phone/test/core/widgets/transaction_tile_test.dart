import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_card.dart';
import 'package:phone/generated/models/student_payment_details_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

TransactionResponse _studentPayment({
  TransactionType type = TransactionType.income,
}) => TransactionResponse(
  id: 'tx-1',
  amount: 3800,
  date: DateTime(2025, 8, 22),
  type: type,
  createdAt: DateTime(2025, 8, 22, 14, 30),
  paymentDetails: StudentPaymentDetailsResponse(
    detailsType: 'STUDENT',
    studentId: 'student-1',
    studentName: 'Ivan Petrov',
    paidUntil: DateTime(2025, 9),
  ),
);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  test('student payments use the income arrow and keep the student name', () {
    final info = TransactionTileInfo.fromTransaction(
      _studentPayment(),
      overrideTitle: 'Ivan Petrov',
    );

    expect(info.title, 'Ivan Petrov');
    expect(info.icon, Icons.arrow_downward_rounded);
    expect(info.backgroundColor, TransactionTileInfo.incomeColor);
  });

  test('expense transactions use the up arrow and the expense color', () {
    final info = TransactionTileInfo.fromTransaction(
      _studentPayment(type: TransactionType.expense),
      overrideTitle: 'Ivan Petrov',
    );

    expect(info.icon, Icons.arrow_upward_rounded);
    expect(info.backgroundColor, TransactionTileInfo.expenseColor);
  });

  testWidgets('tile renders the arrow icon for student payments', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TransactionTile(
          transaction: _studentPayment(),
          overrideTitle: 'Ivan Petrov',
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward_rounded));

    expect(icon.size, 20);
    expect(icon.color, TransactionTileInfo.incomeColor);
    expect(find.text('IP'), findsNothing);
  });

  testWidgets('transaction list view renders the arrow icon for payments', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TransactionListView(
          transactions: [_studentPayment()],
          overrideTitle: 'Ivan Petrov',
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
  });

  testWidgets('ticket card shows the arrow icon instead of initials', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: TransactionTicketCard(
            transaction: _studentPayment(),
            overrideTitle: 'Ivan Petrov',
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_downward_rounded));

    expect(icon.size, 34);
    expect(icon.color, TransactionTileInfo.incomeColor);
    expect(find.text('IP'), findsNothing);
  });
}
