import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/features/groups/controllers/create_group_controller.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeGroupClient implements GroupControllerClient {
  final List<CreateGroupRequest> createBodies = [];
  Exception? error;

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) async {
    createBodies.add(body);
    final err = error;
    if (err != null) throw err;

    return GroupResponse(
      id: 'group-1',
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
  }) => throw UnimplementedError();

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) => throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

ProviderContainer _container(_FakeGroupClient client) {
  final container = ProviderContainer(
    overrides: [groupServiceProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  test('successful save returns the created group summary', () async {
    final client = _FakeGroupClient();
    final container = _container(client);

    final group = await container
        .read(createGroupControllerProvider.notifier)
        .saveGroup(name: '  Alpha  ', priceText: '100', note: 'First group');

    expect(group, isNotNull);
    expect(group?.id, 'group-1');
    expect(group?.name, 'Alpha');
    expect(group?.defaultPrice, 100);
    expect(group?.note, 'First group');
    expect(client.createBodies.single.name, 'Alpha');
  });

  test('empty name fails validation and returns null', () async {
    final client = _FakeGroupClient();
    final container = _container(client);

    final group = await container
        .read(createGroupControllerProvider.notifier)
        .saveGroup(name: '   ', priceText: null, note: null);

    expect(group, isNull);
    expect(client.createBodies, isEmpty);
    final error = container.read(createGroupControllerProvider).error;
    expect(error, isA<ValidationException>());
  });
}
