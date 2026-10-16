import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final service = ref.watch(groupServiceProvider);
  return GroupRepository(service);
});

class GroupRepository {
  final GroupControllerClient _service;
  List<GroupSummaryResponse>? _cachedGroups;

  new(this._service);

  Future<List<GroupSummaryResponse>> getAllGroups({
    bool forceRefresh = false,
  }) async {
    final cached = _cachedGroups;

    if (!forceRefresh && cached != null) {
      return List.unmodifiable(cached);
    }

    return guardApiCall(() async {
      final groups = await _service.getAllGroupsSummary();
      _cachedGroups = groups;

      return List.unmodifiable(groups);
    });
  }

  Future<GroupResponse> createGroup(CreateGroupRequest request) =>
      guardApiCall(() => _service.createGroup(body: request));

  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => guardApiCall(() => _service.updateGroup(groupId: groupId, body: body));

  Future<void> deleteGroup(String groupId) => guardApiCall(() async {
    await _service.deleteGroup(groupId: groupId);

    final cached = _cachedGroups;

    if (cached != null) {
      _cachedGroups = cached.where((group) => group.id != groupId).toList();
    }
  });

  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) => guardApiCall(
    () => _service.getGroupLessons(groupId: groupId, from: from, to: to),
  );

  Future<List<GroupStudentSummaryResponse>> getGroupStudents(String groupId) =>
      guardApiCall(() => _service.getGroupStudents(groupId: groupId));

  Future<void> setGroupStudents({
    required String groupId,
    required Set<String> studentIds,
  }) => guardApiCall(
    () => _service.updateGroup(
      groupId: groupId,
      body: <String, dynamic>{'studentIds': studentIds.toList()},
    ),
  );

  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => guardApiCall(
    () => _service.getGroupReport(groupId: groupId, year: year, month: month),
  );

  void clearCache() {
    _cachedGroups = null;
  }
}
