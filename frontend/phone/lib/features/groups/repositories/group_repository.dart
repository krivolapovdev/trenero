import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/group_report_response.dart';
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
    if (!forceRefresh && _cachedGroups != null) {
      return List.unmodifiable(_cachedGroups!);
    }

    try {
      final groups = await _service.getAllGroupsSummary();
      _cachedGroups = groups;
      return List.unmodifiable(_cachedGroups!);
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }

  List<GroupSummaryResponse> getCachedGroups() {
    if (_cachedGroups == null) return const [];
    return List.unmodifiable(_cachedGroups!);
  }

  //
  // Future<GroupSummary> createGroup(CreateGroupRequest request) async {
  //   try {
  //     // 1. Отправляем запрос на сервер
  //     final newGroup = await _service.createGroup(body: request);
  //
  //     // 2. Обновляем локальный кэш в памяти
  //     if (_cachedGroups != null) {
  //       // Создаем новый иммутабельный список с добавленным элементом
  //       _cachedGroups = [..._cachedGroups!, newGroup];
  //     } else {
  //       _cachedGroups = [newGroup];
  //     }
  //
  //     // 3. Возвращаем созданную группу
  //     return newGroup;
  //   } on DioException catch (e) {
  //     throw Exception('Error creating group: ${e.message}');
  //   }
  // }

  /// Удаление группы с автоматической очисткой из кэша
  Future<void> deleteGroup(String groupId) async {
    try {
      await _service.deleteGroup(groupId: groupId);

      if (_cachedGroups != null) {
        _cachedGroups = _cachedGroups!.where((g) => g.id != groupId).toList();
      }
    } on DioException catch (e) {
      throw Exception('Error deleting group: ${e.message}');
    }
  }

  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _service.getGroupLessons(
        groupId: groupId,
        from: from,
        to: to,
      );
    } on DioException catch (e) {
      throw Exception('Failed to fetch group lessons: ${e.message}');
    }
  }

  Future<List<GroupStudentSummaryResponse>> getGroupStudents(
    String groupId,
  ) async {
    try {
      return await _service.getGroupStudents(groupId: groupId);
    } on DioException catch (e) {
      throw Exception('Failed to fetch group students: ${e.message}');
    }
  }

  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) async {
    try {
      return await _service.getGroupReport(
        groupId: groupId,
        year: year,
        month: month,
      );
    } on DioException catch (e) {
      throw Exception('Failed to fetch group report: ${e.message}');
    }
  }

  void clearCache() {
    _cachedGroups = null;
  }
}
