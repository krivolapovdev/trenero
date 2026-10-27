import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/widgets/create_group_bottom_sheet.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeGroupClient implements GroupControllerClient {
  Completer<GroupResponse>? completer;
  final List<CreateGroupRequest> createBodies = [];

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) async {
    createBodies.add(body);
    final c = completer;
    if (c != null) {
      return c.future;
    }
    return GroupResponse(
      id: 'group-new',
      name: body.name,
      createdAt: DateTime(2026, 1, 1),
      defaultPrice: body.defaultPrice,
      note: body.note,
    );
  }

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() async => const [];

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async => const [];

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) async => const [];

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required _FakeGroupClient client,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [groupServiceProvider.overrideWithValue(client)],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppBottomSheet.show(
                  context: context,
                  child: const CreateGroupBottomSheet(),
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
    'on create group opens group page when bottom sheet is not closed',
    (tester) async {
      final client = _FakeGroupClient();
      await _pumpApp(tester, client: client);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateGroupBottomSheet), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Super Group');
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.create));
      await tester.pumpAndSettle();

      expect(find.byType(CreateGroupBottomSheet), findsNothing);
      expect(find.byType(GroupPage), findsOneWidget);
      expect(find.text('Super Group'), findsOneWidget);
    },
  );

  testWidgets(
    'on create group does not open group page if bottom sheet was closed before save finishes',
    (tester) async {
      final client = _FakeGroupClient();
      client.completer = Completer<GroupResponse>();
      await _pumpApp(tester, client: client);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateGroupBottomSheet), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Super Group');
      await tester.pumpAndSettle();

      await tester.tap(find.text(t.create));
      await tester.pump(); // starts save

      // Close the bottom sheet by popping it while request is pending
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.byType(CreateGroupBottomSheet), findsNothing);

      // Now complete the server request
      client.completer!.complete(
        GroupResponse(
          id: 'group-new',
          name: 'Super Group',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      await tester.pumpAndSettle();

      // GroupPage must NOT be opened because bottom sheet was closed
      expect(find.byType(GroupPage), findsNothing);
    },
  );
}
