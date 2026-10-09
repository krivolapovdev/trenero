import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/features/students/widgets/student_group_bottom_sheet.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

final List<GroupSummaryResponse> _groups = [
  GroupSummaryResponse(
    id: 'group-1',
    name: 'Beginners',
    createdAt: DateTime(2025, 1, 1),
  ),
  GroupSummaryResponse(
    id: 'group-2',
    name: 'Advanced',
    createdAt: DateTime(2025, 1, 2),
  ),
];

final List<StudentSummaryResponse> _students = [
  StudentSummaryResponse(
    id: 'student-1',
    fullName: 'Ivan Petrov',
    createdAt: DateTime(2025, 1, 1),
    statuses: const [],
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;
}

class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => _students;

  @override
  Future<void> getAllStudents({bool forceRefresh = false}) async {}
}

/// Captures the group assignment the sheet sends through `PATCH /students/{id}`.
class _FakeStudentClient implements StudentControllerClient {
  String? assignedGroupId;
  String? assignedJoinedAt;

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) async {
    assignedGroupId = body['groupId'] as String?;
    assignedJoinedAt = body['joinedAt'] as String?;

    return StudentResponse(
      id: studentId,
      fullName: 'Ivan Petrov',
      createdAt: DateTime(2025, 1, 1),
    );
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => _students;

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
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
  }) => throw UnimplementedError();
}

Widget _wrap(_FakeStudentClient client, {String? initialGroupId}) =>
    ProviderScope(
      overrides: [
        studentServiceProvider.overrideWithValue(client),
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
        studentListControllerProvider.overrideWith(
          _FakeStudentListController.new,
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => AppBottomSheet.show(
                    context: context,
                    child: StudentGroupBottomSheet(
                      studentId: 'student-1',
                      initialGroupId: initialGroupId,
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the save button waits for a group to be picked', (tester) async {
    await tester.pumpWidget(_wrap(_FakeStudentClient()));
    await _openSheet(tester);

    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, t.update))
          .onPressed,
      isNull,
    );
  });

  testWidgets('saving assigns the picked group and defaults to today', (
    tester,
  ) async {
    final client = _FakeStudentClient();

    await tester.pumpWidget(_wrap(client));
    await _openSheet(tester);

    await tester.tap(find.byIcon(FluentIcons.chevron_down_24_regular));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, t.update));
    await tester.pumpAndSettle();

    expect(client.assignedGroupId, 'group-2');
    expect(
      client.assignedJoinedAt,
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  });

  testWidgets('an already assigned group is preselected', (tester) async {
    await tester.pumpWidget(
      _wrap(_FakeStudentClient(), initialGroupId: 'group-1'),
    );
    await _openSheet(tester);

    expect(find.text('Beginners'), findsOneWidget);

    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, t.update))
          .onPressed,
      isNotNull,
    );
  });
}
