import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/pages/student_payment_list_page.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _student = StudentSummaryResponse(
  id: 'student-1',
  fullName: 'Ivan Petrov',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroup: GroupResponse(
    id: 'group-a',
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
    defaultPrice: 3800,
  ),
);

class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => const [];
}

/// Answers the payments call of the page with an empty list, so the list shows
/// its empty state without touching the network.
class _FakeStudentPaymentsController extends StudentPaymentsController {
  new(super.studentId);

  @override
  Future<List<TransactionResponse>> build() async => const [];
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

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    container = ProviderContainer(
      overrides: [
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
        studentPaymentsControllerProvider.overrideWith2(
          (studentId) => _FakeStudentPaymentsController(studentId),
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
}
