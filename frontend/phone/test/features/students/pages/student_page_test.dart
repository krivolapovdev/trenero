import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

const String _studentId = 'student-1';

StudentSummaryResponse _student({GroupResponse? group}) =>
    StudentSummaryResponse(
      id: _studentId,
      fullName: 'Ivan Petrov',
      createdAt: DateTime(2025, 1, 1),
      statuses: const [],
      studentGroup: group,
    );

/// Answers the student endpoints used by the page and by the payment sheet.
class _FakeStudentClient implements StudentControllerClient {
  final List<String> paymentStudentIds = [];

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => [
    _student(),
    StudentSummaryResponse(
      id: 'student-2',
      fullName: 'Anna Smirnova',
      createdAt: DateTime(2025, 1, 2),
      statuses: const [],
    ),
  ];

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) async => const [];

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    String? from,
    String? to,
  }) async => const [];

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) async {
    paymentStudentIds.add(studentId);

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
}

class _FakeLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.en;
}

/// The section names the calendars of the student through the groups of the
/// trainer, which are empty for the page under test.
class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => const [];
}

Widget _wrap(StudentSummaryResponse student, _FakeStudentClient client) =>
    ProviderScope(
      overrides: [
        studentServiceProvider.overrideWithValue(client),
        languageProvider.overrideWith(_FakeLanguageNotifier.new),
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
      ],
      child: TranslationProvider(
        child: MaterialApp(home: StudentPage(student: student)),
      ),
    );

/// The payment sheet shows the paid until field only when a student is picked.
Finder get _paidUntilField => find.text('${t.finance.paidUntil}*');

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the app bar menu creates a payment for the student', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_student(), _FakeStudentClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Payment'), findsOneWidget);

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTransactionBottomSheet), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsWidgets);
    expect(_paidUntilField, findsOneWidget);
    // Payments are always income, so the type selector is not offered.
    expect(find.text('Доход'), findsNothing);
    expect(find.text('Расход'), findsNothing);
  });

  testWidgets('the payment sheet prefills the amount with the group price', (
    tester,
  ) async {
    final student = _student(
      group: GroupResponse(
        id: 'group-1',
        name: 'Beginners',
        createdAt: DateTime(2025, 1, 1),
        defaultPrice: 5999,
      ),
    );

    await tester.pumpWidget(_wrap(student, _FakeStudentClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Payment'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTransactionBottomSheet), findsOneWidget);

    // The amount is the first text field of the sheet.
    final amountField = tester.widget<TextField>(find.byType(TextField).first);

    expect(amountField.controller!.text, '5999');
  });

  testWidgets('the floating button creates a payment for the student', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_student(), _FakeStudentClient()));
    await tester.pumpAndSettle();

    // The actions are hidden until the radial button is expanded.
    await tester.tap(find.byType(AnimatedIcon));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.payments));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTransactionBottomSheet), findsOneWidget);
    expect(_paidUntilField, findsOneWidget);
  });
}
