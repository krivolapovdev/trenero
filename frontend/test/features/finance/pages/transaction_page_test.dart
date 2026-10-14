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
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/metric_controller/metric_controller_client.dart';
import 'package:phone/generated/models/create_transaction_request.dart';
import 'package:phone/generated/models/metric_scope.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/models/payment_metric_response.dart';
import 'package:phone/generated/models/student_payment_details_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
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

class _CountingStudentClient implements StudentControllerClient {
  int paymentRequests = 0;

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) async {
    paymentRequests++;

    return const [];
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap(Widget child) => ProviderScope(
  child: TranslationProvider(child: MaterialApp(home: child)),
);

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

TextButton _editAction(WidgetTester tester) =>
    tester.widget<TextButton>(find.widgetWithText(TextButton, t.update));

Finder _paidUntilField() =>
    find.widgetWithText(TextField, '${t.finance.paidUntil}*');

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
  testWidgets('the app bar menu offers edit and delete', (tester) async {
    await tester.pumpWidget(
      _wrap(TransactionPage(transaction: _transaction())),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text(t.edit), findsOneWidget);
    expect(find.text(t.delete), findsOneWidget);

    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(find.byType(EditTransactionBottomSheet), findsOneWidget);
    expect(find.text(t.finance.editTransaction), findsOneWidget);
    expect(find.text('3800'), findsOneWidget);
  });

  testWidgets('the edit sheet waits for the amount to change', (tester) async {
    await tester.pumpWidget(
      _wrap(TransactionPage(transaction: _transaction())),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(_editAction(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '4200');
    await tester.pump();

    expect(_editAction(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField).first, '3800');
    await tester.pump();

    expect(_editAction(tester).onPressed, isNull);
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
    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '4200');
    await tester.pump();
    await tester.tap(find.text(t.update));
    await tester.pump();

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

  testWidgets('the edit sheet hides paid until for plain transactions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(TransactionPage(transaction: _transaction())),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(find.byType(EditTransactionBottomSheet), findsOneWidget);
    expect(_paidUntilField(), findsNothing);
  });

  testWidgets('editing a student payment can change the paid until date', (
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
    final client = _FakeTransactionClient(transaction: transaction);

    await tester.pumpWidget(
      _wrapWithApi(TransactionPage(transaction: transaction), client),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(_paidUntilField(), findsOneWidget);
    expect(
      tester.widget<TextField>(_paidUntilField()).controller!.text,
      '01.09.2025',
    );

    await tester.enterText(_paidUntilField(), '01102025');
    await tester.pump();

    await tester.tap(find.text(t.update));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(client.updateBodies, hasLength(1));
    expect(client.updateBodies.single, {
      'amount': 3800.0,
      'date': '2025-08-22',
      'paidUntil': '2025-10-01',
    });
    expect(find.byType(EditTransactionBottomSheet), findsNothing);
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

  testWidgets('editing a student payment refreshes the student payments', (
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
    final client = _FakeTransactionClient(transaction: transaction);
    final studentClient = _CountingStudentClient();

    final container = ProviderContainer(
      overrides: [
        transactionServiceProvider.overrideWithValue(client),
        metricServiceProvider.overrideWithValue(_FakeMetricClient()),
        studentServiceProvider.overrideWithValue(studentClient),
      ],
    );
    addTearDown(container.dispose);

    // The student page keeps the payments provider alive while it is shown, so
    // the refresh after an edit reloads the recent transactions right away.
    container.listen(
      studentPaymentsControllerProvider('student-1'),
      (_, _) {},
      fireImmediately: true,
    );
    await container.read(studentPaymentsControllerProvider('student-1').future);

    expect(studentClient.paymentRequests, 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(home: TransactionPage(transaction: transaction)),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '4200');
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, t.update));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(client.updateBodies, hasLength(1));
    expect(studentClient.paymentRequests, 2);
  });
}
