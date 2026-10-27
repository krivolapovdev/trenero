import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/rosters/services/roster_service.dart';
import 'package:phone/generated/export.dart';

final rosterRepositoryProvider = Provider<RosterRepository>((ref) {
  final service = ref.watch(rosterServiceProvider);
  return RosterRepository(service);
});

class RosterRepository {
  final RosterControllerClient _service;
  List<RosterResponse>? _cachedRosters;

  new(this._service);

  Future<List<RosterResponse>> getAllRosters({
    bool forceRefresh = false,
  }) async {
    final cached = _cachedRosters;

    if (!forceRefresh && cached != null) {
      return List.unmodifiable(cached);
    }

    return guardApiCall(() async {
      final rosters = await _service.getAllRosters();
      _cachedRosters = rosters;
      return List.unmodifiable(rosters);
    });
  }

  Future<RosterResponse> getRosterById(String rosterId) =>
      guardApiCall(() => _service.getRosterById(rosterId: rosterId));

  Future<RosterResponse> createRoster(CreateRosterRequest request) =>
      guardApiCall(() async {
        final result = await _service.createRoster(body: request);
        clearCache();
        return result;
      });

  Future<RosterResponse> updateRoster({
    required String rosterId,
    required Map<String, dynamic> body,
  }) => guardApiCall(() async {
    final result = await _service.updateRoster(rosterId: rosterId, body: body);
    clearCache();
    return result;
  });

  Future<void> deleteRoster(String rosterId) => guardApiCall(() async {
    await _service.deleteRoster(rosterId: rosterId);
    final cached = _cachedRosters;
    if (cached != null) {
      _cachedRosters = cached.where((r) => r.id != rosterId).toList();
    }
  });

  Future<List<StudentResponse>> getRosterStudents(String rosterId) =>
      guardApiCall(() => _service.getRosterStudents(rosterId: rosterId));

  Future<RosterResponse> addStudentsToRoster({
    required String rosterId,
    required List<String> studentIds,
    String? note,
  }) => guardApiCall(() async {
    final result = await _service.addStudentsToRoster(
      rosterId: rosterId,
      body: AddRosterStudentsRequest(studentIds: studentIds, note: note),
    );
    clearCache();
    return result;
  });

  Future<void> updateRosterStudentNote({
    required String rosterId,
    required String studentId,
    String? note,
  }) => guardApiCall(() async {
    await _service.updateRosterStudentNote(
      rosterId: rosterId,
      studentId: studentId,
      body: UpdateRosterStudentNoteRequest(note: note),
    );
    clearCache();
  });

  Future<void> removeStudentFromRoster({
    required String rosterId,
    required String studentId,
  }) => guardApiCall(() async {
    await _service.removeStudentFromRoster(
      rosterId: rosterId,
      studentId: studentId,
    );
    clearCache();
  });

  void clearCache() {
    _cachedRosters = null;
  }
}
