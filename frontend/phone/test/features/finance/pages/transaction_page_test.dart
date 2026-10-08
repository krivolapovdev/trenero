import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_card.dart';
import 'package:phone/generated/models/student_payment_details_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';

const String _transactionId = '0120077398910288';

TransactionResponse _transaction({
  TransactionType type = TransactionType.income,
  StudentPaymentDetailsResponse? paymentDetails,
}) => TransactionResponse(
  id: _transactionId,
  amount: 3800,
  date: DateTime(2025, 8, 22),
  type: type,
  createdAt: DateTime(2025, 8, 22, 14, 30),
  paymentDetails: paymentDetails,
);

Widget _wrap(Widget child) =>
    TranslationProvider(child: MaterialApp(home: child));

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('tapping a transaction tile opens the transaction page', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: TransactionListView(
            transactions: [_transaction()],
            onRefresh: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TransactionTile));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionPage), findsOneWidget);
    expect(find.text(_transactionId), findsOneWidget);
  });

  testWidgets('tiles are not tappable while the list is loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: TransactionListView(
            transactions: [_transaction()],
            isLoading: true,
            onRefresh: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TransactionTile));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionPage), findsNothing);
  });

  testWidgets('transaction page shows the ticket header and all details', (
    tester,
  ) async {
    final transaction = _transaction();

    await tester.pumpWidget(_wrap(TransactionPage(transaction: transaction)));

    expect(find.text(t.finance.transactionTitle), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);

    expect(find.text(t.finance.transactionId.toUpperCase()), findsOneWidget);
    expect(find.text(_transactionId), findsOneWidget);
    expect(find.text(t.finance.date.toUpperCase()), findsOneWidget);
    expect(find.text('22 AUG, 2025'), findsOneWidget);
    expect(find.text(t.finance.amount.toUpperCase()), findsOneWidget);
    expect(find.text(3800.toFormattedAmount()), findsOneWidget);
    expect(find.text(t.finance.type.toUpperCase()), findsOneWidget);
    expect(find.text(t.finance.typeIncome), findsOneWidget);
    expect(find.text(t.finance.createdAt.toUpperCase()), findsOneWidget);
    expect(find.text('22 AUG, 2025 14:30'), findsOneWidget);
  });

  testWidgets('transaction page shows the student payment details', (
    tester,
  ) async {
    final transaction = _transaction(
      paymentDetails: StudentPaymentDetailsResponse(
        detailsType: 'STUDENT',
        studentId: 'student-1',
        studentName: 'Ivan Petrov',
        paidUntil: DateTime(2025, 9),
      ),
    );

    await tester.pumpWidget(
      _wrap(
        TransactionPage(transaction: transaction, overrideTitle: 'Ivan P.'),
      ),
    );

    final ticketTitle = find.descendant(
      of: find.byType(TransactionTicketCard),
      matching: find.text('Ivan P.'),
    );

    expect(ticketTitle, findsOneWidget);
    expect(find.text(t.finance.student.toUpperCase()), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text(t.finance.paidUntil.toUpperCase()), findsOneWidget);
    expect(find.text('1 SEP, 2025'), findsOneWidget);
  });
}
