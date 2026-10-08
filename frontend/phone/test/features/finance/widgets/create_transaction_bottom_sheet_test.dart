import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/finance/services/metric_service.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/metric_controller/metric_controller_client.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/create_transaction_request.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/metric_scope.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/models/payment_metric_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

StudentSummaryResponse _student({
  required String id,
  required String fullName,
  GroupResponse? group,
}) => StudentSummaryResponse(
  id: id,
  fullName: fullName,
  createdAt: DateTime(2025, 1, 1),
  statuses: const [],
  studentGroup: group,
);

GroupResponse _group({required num defaultPrice}) => GroupResponse(
  id: 'group-1',
  name: 'Beginners',
  createdAt: DateTime(2025, 1, 1),
  defaultPrice: defaultPrice,
);

/// Answers the student endpoints and records the created student payments.
class _FakeStudentClient implements StudentControllerClient {
  new({this.studentsSummary});

  /// Served instead of the default students when set.
  final List<StudentSummaryResponse>? studentsSummary;

  /// When set, [createStudentPayment] waits for it before answering.
  Completer<void>? paymentGate;

  final List<String> paymentStudentIds = [];
  final List<CreateStudentPaymentRequest> paymentBodies = [];

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async =>
      studentsSummary ??
      [
        _student(id: 'student-1', fullName: 'Ivan Petrov'),
        _student(id: 'student-2', fullName: 'Anna Smirnova'),
      ];

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) async {
    final gate = paymentGate;
    if (gate != null) await gate.future;

    paymentStudentIds.add(studentId);
    paymentBodies.add(body);

    return TransactionResponse(
      id: 'payment-1',
      amount: body.amount,
      date: body.date,
      type: TransactionType.income,
      createdAt: DateTime(2025, 8, 22),
    );
  }

  @override
  Future<List<StudentResponse>> getStudents() => throw UnimplementedError();

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> getStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();
}

/// Records the created transactions and serves an empty page.
class _FakeTransactionClient implements TransactionControllerClient {
  final List<CreateTransactionRequest> createBodies = [];

  @override
  Future<TransactionResponse> createTransaction({
    required CreateTransactionRequest body,
  }) async {
    createBodies.add(body);

    return TransactionResponse(
      id: 'transaction-1',
      amount: body.amount,
      date: body.date,
      type: body.type,
      createdAt: DateTime(2025, 8, 22),
    );
  }

  @override
  Future<PageTransactionResponse> getPaginatedTransactions({
    int? page = 1,
    int? size = 20,
  }) async => const PageTransactionResponse(content: [], totalElements: 0);

  @override
  Future<TransactionResponse> getTransactionById({
    required String transactionId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteTransaction({required String transactionId}) =>
      throw UnimplementedError();
}

class _FakeMetricClient implements MetricControllerClient {
  @override
  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
    MetricScope? scope = MetricScope.month,
  }) async => const [];
}

Widget _wrap(
  Widget child, {
  required _FakeStudentClient studentClient,
  required _FakeTransactionClient transactionClient,
}) => ProviderScope(
  overrides: [
    studentServiceProvider.overrideWithValue(studentClient),
    transactionServiceProvider.overrideWithValue(transactionClient),
    metricServiceProvider.overrideWithValue(_FakeMetricClient()),
  ],
  child: TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                AppBottomSheet.show(context: context, child: child),
            child: const Text('open sheet'),
          ),
        ),
      ),
    ),
  ),
);

/// Opens the bottom sheet the same way the finance page does.
Future<void> _openSheet(
  WidgetTester tester, {
  required _FakeStudentClient studentClient,
  required _FakeTransactionClient transactionClient,
  Widget sheet = const CreateTransactionBottomSheet(),
}) async {
  await tester.pumpWidget(
    _wrap(
      sheet,
      studentClient: studentClient,
      transactionClient: transactionClient,
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

/// The date field and the student field share the same chevron icon, the
/// student field is rendered last.
Finder get _studentField =>
    find.byIcon(FluentIcons.chevron_down_24_regular).last;

Future<void> _pickStudent(WidgetTester tester, String fullName) async {
  await tester.tap(_studentField);
  await tester.pumpAndSettle();

  await tester.tap(find.text(fullName));
  await tester.pumpAndSettle();
}

/// The sheet prefills the paid until date with one month from the payment date.
DateTime _defaultPaidUntil() {
  final now = DateTime.now();

  return DateTime(now.year, now.month + 1, now.day);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.${date.year}';
}

/// The amount is the first text field of the sheet.
String _amountText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.text('Создать'));
  await tester.pump();

  // The transaction list and the metrics are reloaded with a delay.
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the student field is only offered for income transactions', (
    tester,
  ) async {
    await _openSheet(
      tester,
      studentClient: _FakeStudentClient(),
      transactionClient: _FakeTransactionClient(),
    );

    expect(find.text(t.finance.student), findsOneWidget);
    expect(find.text(t.students.noStudent), findsOneWidget);

    await tester.tap(find.text('Расход'));
    await tester.pumpAndSettle();

    expect(find.text(t.finance.student), findsNothing);
    expect(find.text(t.students.noStudent), findsNothing);
  });

  testWidgets('the student options are hidden until the field is tapped', (
    tester,
  ) async {
    await _openSheet(
      tester,
      studentClient: _FakeStudentClient(),
      transactionClient: _FakeTransactionClient(),
    );

    expect(find.byIcon(FluentIcons.chevron_down_24_regular), findsNWidgets(2));
    expect(find.text('Ivan Petrov'), findsNothing);
    expect(find.text('Anna Smirnova'), findsNothing);

    await tester.tap(_studentField);
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.chevron_up_24_regular), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);
  });

  testWidgets('picking a student reveals the paid until field with a default', (
    tester,
  ) async {
    await _openSheet(
      tester,
      studentClient: _FakeStudentClient(),
      transactionClient: _FakeTransactionClient(),
    );

    expect(find.text('${t.finance.paidUntil}*'), findsNothing);

    await _pickStudent(tester, 'Ivan Petrov');

    // The options are collapsed and the picked student is shown by the field.
    expect(find.byIcon(FluentIcons.chevron_down_24_regular), findsNWidgets(2));
    expect(find.text('Ivan Petrov'), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsNothing);
    expect(find.text('${t.finance.paidUntil}*'), findsOneWidget);
    expect(find.text(_formatDate(_defaultPaidUntil())), findsOneWidget);
  });

  testWidgets('the amount is prefilled with the given initial amount', (
    tester,
  ) async {
    await _openSheet(
      tester,
      studentClient: _FakeStudentClient(),
      transactionClient: _FakeTransactionClient(),
      sheet: const CreateTransactionBottomSheet(
        initialStudentId: 'student-1',
        initialAmount: 5999,
        isIncomeOnly: true,
      ),
    );

    expect(_amountText(tester), '5999');
  });

  testWidgets('picking a student fills the amount with the group price', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient(
      studentsSummary: [
        _student(
          id: 'student-1',
          fullName: 'Ivan Petrov',
          group: _group(defaultPrice: 5999),
        ),
        _student(
          id: 'student-2',
          fullName: 'Anna Smirnova',
          group: _group(defaultPrice: 4500.5),
        ),
        _student(id: 'student-3', fullName: 'Oleg Sidorov'),
      ],
    );

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: _FakeTransactionClient(),
    );

    await _pickStudent(tester, 'Ivan Petrov');

    expect(_amountText(tester), '5999');

    // Without a group the amount stays as it is.
    await _pickStudent(tester, 'Oleg Sidorov');

    expect(_amountText(tester), '5999');

    // Another group price replaces the auto-filled amount.
    await _pickStudent(tester, 'Anna Smirnova');

    expect(_amountText(tester), '4500.5');
  });

  testWidgets('a sum typed by the user is kept when a student is picked', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient(
      studentsSummary: [
        _student(
          id: 'student-1',
          fullName: 'Ivan Petrov',
          group: _group(defaultPrice: 5999),
        ),
      ],
    );

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: _FakeTransactionClient(),
    );

    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.pump();

    await _pickStudent(tester, 'Ivan Petrov');

    expect(_amountText(tester), '1500');
  });

  testWidgets('the group price of a picked student is used for saving', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient(
      studentsSummary: [
        _student(
          id: 'student-2',
          fullName: 'Anna Smirnova',
          group: _group(defaultPrice: 5999),
        ),
      ],
    );

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: _FakeTransactionClient(),
      sheet: const CreateTransactionBottomSheet(
        initialStudentId: 'student-2',
        initialAmount: 5999,
        isIncomeOnly: true,
      ),
    );

    await _save(tester);

    expect(studentClient.paymentStudentIds, ['student-2']);
    expect(studentClient.paymentBodies.single.amount, 5999);
  });

  testWidgets('an income with a student is saved as a student payment', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
    );

    await tester.enterText(find.byType(TextField).first, '5000');
    await tester.pump();

    await _pickStudent(tester, 'Ivan Petrov');

    await _save(tester);

    expect(studentClient.paymentStudentIds, ['student-1']);
    expect(studentClient.paymentBodies, hasLength(1));

    final body = studentClient.paymentBodies.single;
    expect(body.amount, 5000);
    expect(_dateOnly(body.date), _dateOnly(DateTime.now()));
    expect(_dateOnly(body.paidUntil), _defaultPaidUntil());
    expect(transactionClient.createBodies, isEmpty);
    expect(find.byType(CreateTransactionBottomSheet), findsNothing);
  });

  testWidgets('an income without a student is saved as a plain transaction', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
    );

    await tester.enterText(find.byType(TextField).first, '1200');
    await tester.pump();

    await _save(tester);

    expect(studentClient.paymentBodies, isEmpty);
    expect(transactionClient.createBodies, hasLength(1));
    expect(transactionClient.createBodies.single.type, TransactionType.income);
    expect(transactionClient.createBodies.single.amount, 1200);
  });

  testWidgets('an expense stays a plain transaction even after a student was '
      'picked', (tester) async {
    final studentClient = _FakeStudentClient();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
    );

    await _pickStudent(tester, 'Ivan Petrov');

    await tester.tap(find.text('Расход'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '300');
    await tester.pump();

    await _save(tester);

    expect(studentClient.paymentBodies, isEmpty);
    expect(transactionClient.createBodies, hasLength(1));
    expect(transactionClient.createBodies.single.type, TransactionType.expense);
  });

  testWidgets('the sheet can be opened for an already picked student', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
      sheet: const CreateTransactionBottomSheet(initialStudentId: 'student-2'),
    );

    // The student is shown by the field and the paid until date is prefilled.
    expect(find.text('Anna Smirnova'), findsOneWidget);
    expect(find.text(t.students.noStudent), findsNothing);
    expect(find.text('${t.finance.paidUntil}*'), findsOneWidget);
    expect(find.text(_formatDate(_defaultPaidUntil())), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '900');
    await tester.pump();

    await _save(tester);

    expect(studentClient.paymentStudentIds, ['student-2']);
    expect(studentClient.paymentBodies.single.amount, 900);
    expect(transactionClient.createBodies, isEmpty);
  });

  testWidgets('the student section is closed and disabled while saving', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient()..paymentGate = Completer<void>();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
    );

    await tester.enterText(find.byType(TextField).first, '700');
    await tester.pump();
    await _pickStudent(tester, 'Ivan Petrov');

    // The options are re-opened before saving.
    await tester.tap(_studentField);
    await tester.pumpAndSettle();
    expect(find.text('Anna Smirnova'), findsOneWidget);

    await tester.ensureVisible(find.text('Создать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать'));
    await tester.pump();

    // The section is closed and the form is disabled while the request is in
    // flight.
    expect(find.text('Anna Smirnova'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).enabled,
      false,
    );

    await tester.tap(_studentField, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Anna Smirnova'), findsNothing);

    studentClient.paymentGate!.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(studentClient.paymentBodies, hasLength(1));
    expect(find.byType(CreateTransactionBottomSheet), findsNothing);
  });

  testWidgets('the type selector is hidden for income only sheets', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
      sheet: const CreateTransactionBottomSheet(
        initialStudentId: 'student-1',
        isIncomeOnly: true,
      ),
    );

    expect(find.text('Доход'), findsNothing);
    expect(find.text('Расход'), findsNothing);
    expect(find.text('${t.finance.paidUntil}*'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '1500');
    await tester.pump();

    await _save(tester);

    expect(studentClient.paymentStudentIds, ['student-1']);
    expect(studentClient.paymentBodies.single.amount, 1500);
    expect(transactionClient.createBodies, isEmpty);
  });

  testWidgets('the date section is closed and disabled while saving', (
    tester,
  ) async {
    final studentClient = _FakeStudentClient()..paymentGate = Completer<void>();
    final transactionClient = _FakeTransactionClient();

    await _openSheet(
      tester,
      studentClient: studentClient,
      transactionClient: transactionClient,
    );

    await tester.enterText(find.byType(TextField).first, '700');
    await tester.pump();
    await _pickStudent(tester, 'Ivan Petrov');

    // The calendar opens while the form is idle.
    await tester.tap(find.text(_formatDate(DateTime.now())));
    await tester.pumpAndSettle();
    expect(find.byType(SfDateRangePicker), findsOneWidget);

    await tester.ensureVisible(find.text('Создать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать'));
    await tester.pump();

    // The calendar is closed while the request is in flight.
    expect(find.byType(SfDateRangePicker), findsNothing);

    await tester.ensureVisible(find.text(_formatDate(DateTime.now())));
    await tester.pump();
    await tester.tap(
      find.text(_formatDate(DateTime.now())),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(find.byType(SfDateRangePicker), findsNothing);

    studentClient.paymentGate!.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(studentClient.paymentBodies, hasLength(1));
  });
}
