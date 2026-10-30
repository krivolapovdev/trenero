import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/finance/services/metric_service.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/features/groups/controllers/group_payments_controller.dart';
import 'package:phone/features/groups/models/group_student_payment.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/export.dart';

class _FakeStudentClient implements StudentControllerClient {
  final List<CreateStudentPaymentRequest> createdPayments = [];
  final List<String> createdPaymentStudentIds = [];
  bool shouldThrow = false;

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    createdPaymentStudentIds.add(studentId);
    createdPayments.add(body);
    return TransactionResponse(
      amount: body.amount,
      createdAt: DateTime.now(),
      date: body.date,
      id: 'tx-1',
      type: TransactionType.income,
    );
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) async => const [];

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) async => const [];

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

class _FakeTransactionClient implements TransactionControllerClient {
  @override
  Future<PageTransactionResponse> getPaginatedTransactions({
    int? page = 1,
    int? size = 20,
  }) async => const PageTransactionResponse(
    content: [],
    pageable: null,
    totalElements: 0,
    totalPages: 0,
  );

  @override
  Future<TransactionResponse> createTransaction({
    required CreateTransactionRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteTransaction({required String transactionId}) =>
      throw UnimplementedError();

  @override
  Future<TransactionResponse> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

class _FakeMetricClient implements MetricControllerClient {
  @override
  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
    MetricScope? scope = MetricScope.month,
  }) async => const [];
}

ProviderContainer _createContainer({
  required _FakeStudentClient studentClient,
  required _FakeTransactionClient transactionClient,
  required _FakeMetricClient metricClient,
}) {
  final container = ProviderContainer(
    overrides: [
      studentServiceProvider.overrideWithValue(studentClient),
      transactionServiceProvider.overrideWithValue(transactionClient),
      metricServiceProvider.overrideWithValue(metricClient),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('GroupPaymentsController creates payments for each student', () async {
    final fakeStudentClient = _FakeStudentClient();
    final fakeTransactionClient = _FakeTransactionClient();
    final fakeMetricClient = _FakeMetricClient();

    final container = _createContainer(
      studentClient: fakeStudentClient,
      transactionClient: fakeTransactionClient,
      metricClient: fakeMetricClient,
    );

    final controller = container.read(groupPaymentsControllerProvider.notifier);

    final paymentDate = DateTime(2026, 10, 30);
    final paidUntil1 = DateTime(2026, 11, 30);
    final paidUntil2 = DateTime(2026, 12, 30);

    final success = await controller.createPayments(
      groupId: 'group-1',
      paymentDate: paymentDate,
      payments: [
        GroupStudentPaymentItem(
          studentId: 'student-1',
          amount: 3000,
          paidUntil: paidUntil1,
        ),
        GroupStudentPaymentItem(
          studentId: 'student-2',
          amount: 2500,
          paidUntil: paidUntil2,
        ),
      ],
    );

    expect(success, isTrue);
    expect(fakeStudentClient.createdPaymentStudentIds, [
      'student-1',
      'student-2',
    ]);
    expect(fakeStudentClient.createdPayments.length, 2);
    expect(fakeStudentClient.createdPayments[0].amount, 3000);
    expect(fakeStudentClient.createdPayments[0].date, paymentDate);
    expect(fakeStudentClient.createdPayments[0].paidUntil, paidUntil1);
    expect(fakeStudentClient.createdPayments[1].amount, 2500);
    expect(fakeStudentClient.createdPayments[1].date, paymentDate);
    expect(fakeStudentClient.createdPayments[1].paidUntil, paidUntil2);
  });

  test('GroupPaymentsController returns false on error', () async {
    final fakeStudentClient = _FakeStudentClient()..shouldThrow = true;
    final fakeTransactionClient = _FakeTransactionClient();
    final fakeMetricClient = _FakeMetricClient();

    final container = _createContainer(
      studentClient: fakeStudentClient,
      transactionClient: fakeTransactionClient,
      metricClient: fakeMetricClient,
    );

    final controller = container.read(groupPaymentsControllerProvider.notifier);

    final success = await controller.createPayments(
      groupId: 'group-1',
      paymentDate: DateTime(2026, 10, 30),
      payments: [
        GroupStudentPaymentItem(
          studentId: 'student-1',
          amount: 3000,
          paidUntil: DateTime(2026, 11, 30),
        ),
      ],
    );

    expect(success, isFalse);
    expect(container.read(groupPaymentsControllerProvider).hasError, isTrue);
  });
}
