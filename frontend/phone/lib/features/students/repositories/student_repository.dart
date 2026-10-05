import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final service = ref.watch(studentServiceProvider);
  return StudentRepository(service);
});

class StudentRepository {
  final StudentControllerClient _service;
  List<StudentSummaryResponse>? _cachedStudents;

  new(this._service);

  Future<List<StudentSummaryResponse>> getAllStudents({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedStudents != null) {
      return List.unmodifiable(_cachedStudents!);
    }

    try {
      final students = await _service.getStudentsSummary();
      _cachedStudents = students;
      return List.unmodifiable(_cachedStudents!);
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }

  List<StudentSummaryResponse> getCachedStudents() {
    if (_cachedStudents == null) return const [];
    return List.unmodifiable(_cachedStudents!);
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _service.deleteStudent(studentId: studentId);

      if (_cachedStudents != null) {
        _cachedStudents = _cachedStudents!
            .where((s) => s.id != studentId)
            .toList();
      }
    } on DioException catch (e) {
      throw Exception('Error deleting student: ${e.message}');
    }
  }

  void clearCache() {
    _cachedStudents = null;
  }
}
