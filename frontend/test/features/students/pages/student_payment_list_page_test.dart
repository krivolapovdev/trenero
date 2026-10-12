import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/features/students/widgets/student_payments_skeleton.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/student_payment_details_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

final _student = StudentSummaryResponse(
  id: 'student-1',
  fullName: 'Ivan Petrov',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [
    GroupResponse(
      id: 'group-a',
      name: 'Group A',
      createdAt: DateTime(2025, 8, 22),
      defaultPrice: 3800,
    ),
  ],
);

final _payment = TransactionResponse(
  id: 'tx-1',
  amount: 3800,
  date: DateTime(2025, 8, 22),
  type: TransactionType.income,
  createdAt: DateTime(2025, 8, 22, 14, 30),
  paymentDetails: StudentPaymentDetailsResponse(
    detailsType: 'STUDENT',
    studentId: 'student-1',
    studentName: 'Ivan Petrov',
    paidUntil: DateTime(2025, 9),
  ),
);

class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => const [];
}

class _FakeStudentPaymentsController extends StudentPaymentsController {
  new(super.studentId, this.payments, this.onRefresh);

  final List<TransactionResponse> payments;
  final VoidCallback onRefresh;

  @override
  Future<List<TransactionResponse>> build() async => payments;

  @override
  Future<void> refresh() async {
    onRefresh();
    state = AsyncData(payments);
  }
}

class _LoadingStudentPaymentsController extends StudentPaymentsController {
  new(super.studentId);

  @override
  Future<List<TransactionResponse>> build() =>
      Completer<List<TransactionResponse>>().future;
}

Future<void> _pumpPage(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(home: StudentPaymentListPage(student: _student)),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  late ProviderContainer container;
  late List<TransactionResponse> payments;
  late int refreshCount;

  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  setUp(() {
    payments = const [];
    refreshCount = 0;

    container = ProviderContainer(
      overrides: [
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
        studentPaymentsControllerProvider.overrideWith2(
          (studentId) => _FakeStudentPaymentsController(
            studentId,
            payments,
            () => refreshCount++,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('the app bar offers adding a new payment', (tester) async {
    await _pumpPage(tester, container);

    expect(find.byIcon(FluentIcons.savings_24_regular), findsOneWidget);
  });

  testWidgets('tapping the app bar action opens the create payment sheet', (
    tester,
  ) async {
    await _pumpPage(tester, container);

    await tester.tap(find.byIcon(FluentIcons.savings_24_regular));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTransactionBottomSheet), findsOneWidget);
    expect(find.text(t.finance.createTransaction), findsOneWidget);
  });

  testWidgets('a pull to refresh reloads the student payments', (tester) async {
    payments = [_payment];

    await _pumpPage(tester, container);

    expect(find.byType(TransactionListView), findsOneWidget);
    expect(refreshCount, 0);

    await tester.fling(
      find.byType(TransactionListView),
      const Offset(0.0, 300.0),
      1000.0,
    );
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
  });

  testWidgets('the loading state shows the payments skeleton', (tester) async {
    final loadingContainer = ProviderContainer(
      overrides: [
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
        studentPaymentsControllerProvider.overrideWith2(
          _LoadingStudentPaymentsController.new,
        ),
      ],
    );
    addTearDown(loadingContainer.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: loadingContainer,
        child: TranslationProvider(
          child: MaterialApp(home: StudentPaymentListPage(student: _student)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StudentPaymentsSkeleton), findsOneWidget);
    expect(find.byType(SkeletonizerScope), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
