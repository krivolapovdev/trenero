import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/finance/controllers/delete_transaction_controller.dart';
import 'package:phone/features/finance/controllers/update_transaction_controller.dart';
import 'package:phone/features/finance/services/metric_service.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
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

const String _studentId = 'student-1';
const String _transactionId = '0120077398910288';

final _transaction = TransactionResponse(
  id: _transactionId,
  amount: 3800,
  date: DateTime(2025, 8, 22),
  type: TransactionType.income,
  createdAt: DateTime(2025, 8, 22, 14, 30),
  paymentDetails: StudentPaymentDetailsResponse(
    detailsType: 'STUDENT',
    studentId: _studentId,
    studentName: 'Ivan Petrov',
    paidUntil: DateTime(2025, 9),
  ),
);

class _FakeTransactionClient implements TransactionControllerClient {
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
      type: _transaction.type,
      createdAt: _transaction.createdAt,
      paymentDetails: _transaction.paymentDetails,
    );
  }

  @override
  Future<void> deleteTransaction({required String transactionId}) async {
    deletedIds.add(transactionId);
  }
}

class _CountingStudentClient implements StudentControllerClient {
  int paymentRequests = 0;
  int summaryRequests = 0;

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) async {
    paymentRequests++;

    return const [];
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async {
    summaryRequests++;

    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMetricClient implements MetricControllerClient {
  @override
  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
    MetricScope? scope = MetricScope.month,
  }) async => const [];
}

ProviderContainer _container(
  _FakeTransactionClient transactionClient,
  _CountingStudentClient studentClient,
) {
  final container = ProviderContainer(
    overrides: [
      transactionServiceProvider.overrideWithValue(transactionClient),
      studentServiceProvider.overrideWithValue(studentClient),
      metricServiceProvider.overrideWithValue(_FakeMetricClient()),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

// Keeps the student payments of the student alive so invalidating it refetches
// the payments right away, the same way the student page listens to it.
Future<void> _listenToStudentPayments(ProviderContainer container) async {
  container.listen(
    studentPaymentsControllerProvider(_studentId),
    (_, _) {},
    fireImmediately: true,
  );

  await container.read(studentPaymentsControllerProvider(_studentId).future);
}

void main() {
  test(
    'editing a student payment refreshes the payments and the student list',
    () async {
      final studentClient = _CountingStudentClient();
      final container = _container(_FakeTransactionClient(), studentClient);

      await _listenToStudentPayments(container);

      expect(studentClient.paymentRequests, 1);

      final summaryRequestsBefore = studentClient.summaryRequests;

      final updated = await container
          .read(updateTransactionControllerProvider.notifier)
          .updateTransaction(
            transactionId: _transactionId,
            amount: 4200,
            date: DateTime(2025, 8, 22),
            studentId: _studentId,
          );

      await container.read(
        studentPaymentsControllerProvider(_studentId).future,
      );

      expect(updated, isNotNull);
      expect(studentClient.paymentRequests, 2);
      expect(studentClient.summaryRequests, greaterThan(summaryRequestsBefore));
    },
  );

  test(
    'editing a plain transaction leaves the student payments untouched',
    () async {
      final studentClient = _CountingStudentClient();
      final container = _container(_FakeTransactionClient(), studentClient);

      await _listenToStudentPayments(container);

      expect(studentClient.paymentRequests, 1);

      final summaryRequestsBefore = studentClient.summaryRequests;

      await container
          .read(updateTransactionControllerProvider.notifier)
          .updateTransaction(
            transactionId: _transactionId,
            amount: 4200,
            date: DateTime(2025, 8, 22),
          );

      expect(studentClient.paymentRequests, 1);
      expect(studentClient.summaryRequests, summaryRequestsBefore);
    },
  );

  test('deleting a student payment refreshes the payments', () async {
    final transactionClient = _FakeTransactionClient();
    final studentClient = _CountingStudentClient();
    final container = _container(transactionClient, studentClient);

    await _listenToStudentPayments(container);

    expect(studentClient.paymentRequests, 1);

    final deleted = await container
        .read(deleteTransactionControllerProvider.notifier)
        .deleteTransaction(_transactionId, studentId: _studentId);

    await container.read(studentPaymentsControllerProvider(_studentId).future);

    expect(deleted, isTrue);
    expect(transactionClient.deletedIds, [_transactionId]);
    expect(studentClient.paymentRequests, 2);
  });
}
