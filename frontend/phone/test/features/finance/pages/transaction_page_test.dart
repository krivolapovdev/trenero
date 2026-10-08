import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
import 'package:phone/features/finance/services/metric_service.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/features/finance/widgets/delete_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/edit_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/transaction_ticket_card.dart';
import 'package:phone/generated/metric_controller/metric_controller_client.dart';
import 'package:phone/generated/models/create_transaction_request.dart';
import 'package:phone/generated/models/metric_scope.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/models/payment_metric_response.dart';
import 'package:phone/generated/models/student_payment_details_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';
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

/// Records the calls made by the update/delete controllers and answers with
/// the [transaction] the fake was built for.
class _FakeTransactionClient implements TransactionControllerClient {
  new({required this.transaction});

  final TransactionResponse transaction;
  final List<String> deletedIds = [];
  final List<Map<String, dynamic>> updateBodies = [];

  @override
  Future<PageTransactionResponse> getPaginatedTransactions({
    int? page = 1,
    int? size = 20,
  }) async => const PageTransactionResponse(content: [], totalElements: 0);

  @override
  Future<TransactionResponse> createTransaction({
    required CreateTransactionRequest body,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> getTransactionById({
    required String transactionId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> body,
  }) async {
    updateBodies.add(body);

    return TransactionResponse(
      id: transactionId,
      amount: body['amount'] as num,
      date: DateTime.parse(body['date'] as String),
      type: transaction.type,
      createdAt: transaction.createdAt,
      paymentDetails: transaction.paymentDetails,
    );
  }

  @override
  Future<void> deleteTransaction({required String transactionId}) async {
    deletedIds.add(transactionId);
  }
}

class _FakeMetricClient implements MetricControllerClient {
  @override
  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
    MetricScope? scope = MetricScope.month,
  }) async => const [];
}

Widget _wrap(Widget child) => ProviderScope(
  child: TranslationProvider(child: MaterialApp(home: child)),
);

/// Wrapper with the finance API clients replaced by [transactionClient] and an
/// empty metrics client.
Widget _wrapWithApi(
  Widget child,
  TransactionControllerClient transactionClient,
) => ProviderScope(
  overrides: [
    transactionServiceProvider.overrideWithValue(transactionClient),
    metricServiceProvider.overrideWithValue(_FakeMetricClient()),
  ],
  child: TranslationProvider(child: MaterialApp(home: child)),
);

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
  testWidgets('the app bar menu offers update and delete', (tester) async {
    await tester.pumpWidget(
      _wrap(TransactionPage(transaction: _transaction())),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text(t.update), findsOneWidget);
    expect(find.text(t.delete), findsOneWidget);

    await tester.tap(find.text(t.update));
    await tester.pumpAndSettle();

    expect(find.byType(EditTransactionBottomSheet), findsOneWidget);
    expect(find.text(t.finance.editTransaction), findsOneWidget);
    expect(find.text('3800'), findsOneWidget);
  });

  testWidgets('updating a transaction patches it and refreshes the ticket', (
    tester,
  ) async {
    final transaction = _transaction();
    final client = _FakeTransactionClient(transaction: transaction);

    await tester.pumpWidget(
      _wrapWithApi(TransactionPage(transaction: transaction), client),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.update));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '4200');
    await tester.pump();
    await tester.tap(find.text(t.update));
    await tester.pump();

    // The transaction list and the metrics are reloaded with a delay.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(client.updateBodies, hasLength(1));
    expect(client.updateBodies.single, {
      'amount': 4200.0,
      'date': '2025-08-22',
    });
    expect(find.byType(EditTransactionBottomSheet), findsNothing);
    expect(find.text(4200.toFormattedAmount()), findsOneWidget);
  });

  testWidgets('deleting a transaction confirms and returns to the list', (
    tester,
  ) async {
    final transaction = _transaction();
    final client = _FakeTransactionClient(transaction: transaction);

    await tester.pumpWidget(
      _wrapWithApi(
        Scaffold(
          body: TransactionListView(
            transactions: [transaction],
            onRefresh: () async {},
          ),
        ),
        client,
      ),
    );

    await tester.tap(find.byType(TransactionTile));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.delete));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteTransactionBottomSheet), findsOneWidget);
    expect(find.text(t.finance.deleteTransaction), findsOneWidget);
    expect(find.text(t.finance.deleteTransactionMessage), findsOneWidget);

    await tester.tap(find.text(t.delete));
    await tester.pump();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(client.deletedIds, [_transactionId]);
    expect(find.byType(TransactionPage), findsNothing);
    expect(find.byType(TransactionListView), findsOneWidget);
  });
}
