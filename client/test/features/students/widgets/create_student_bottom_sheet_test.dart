import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/features/students/widgets/create_student_bottom_sheet.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeStudentClient implements StudentControllerClient {
  Completer<StudentResponse>? completer;
  final List<CreateStudentRequest> createBodies = [];

  @override
  Future<StudentResponse> createStudent({
    required CreateStudentRequest body,
  }) async {
    createBodies.add(body);
    final c = completer;
    if (c != null) {
      return c.future;
    }
    return StudentResponse(
      id: 'student-new',
      fullName: body.fullName,
      createdAt: DateTime(2026, 1, 1),
      free: body.free ?? false,
    );
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) async => const [];

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();

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
    DateTime? from,
    DateTime? to,
  }) async => const [];
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required _FakeStudentClient client,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [studentServiceProvider.overrideWithValue(client)],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppBottomSheet.show(
                  context: context,
                  child: const CreateStudentBottomSheet(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets(
    'on create student opens student page when bottom sheet is not closed',
    (tester) async {
      final client = _FakeStudentClient();
      await _pumpApp(tester, client: client);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateStudentBottomSheet), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'John Doe');
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.create));
      await tester.pumpAndSettle();

      expect(find.byType(CreateStudentBottomSheet), findsNothing);
      expect(find.byType(StudentPage), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    },
  );

  testWidgets(
    'on create student does not open student page if bottom sheet was closed before save finishes',
    (tester) async {
      final client = _FakeStudentClient();
      client.completer = Completer<StudentResponse>();
      await _pumpApp(tester, client: client);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateStudentBottomSheet), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Jane Doe');
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.create));
      await tester.pump(); // starts save

      // Close the bottom sheet by popping it while request is pending
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.byType(CreateStudentBottomSheet), findsNothing);

      // Now complete the server request
      client.completer!.complete(
        StudentResponse(
          id: 'student-new',
          fullName: 'Jane Doe',
          createdAt: DateTime(2026, 1, 1),
          free: false,
        ),
      );
      await tester.pumpAndSettle();

      // StudentPage must NOT be opened because bottom sheet was closed
      expect(find.byType(StudentPage), findsNothing);
    },
  );
}
