import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final service = ref.watch(studentServiceProvider);
  return StudentRepository(service);
});

class StudentRepository {
  final StudentControllerClient _service;
  List<StudentSummaryResponse>? _cachedStudents;

  /// `PATCH /api/v1/students/{studentId}` parses `joinedAt` with `LocalDate.parse`
  /// on the backend, so a plain `yyyy-MM-dd` value is required (an ISO date-time
  /// would fail, the same way the birthdate does).
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

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

  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _service.getStudentVisits(studentId: studentId);
    } on DioException catch (e) {
      throw Exception('Failed to fetch student lessons: ${e.message}');
    }
  }

  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _service.getStudentPayments(studentId: studentId);
    } on DioException catch (e) {
      throw Exception('Failed to fetch student lessons: ${e.message}');
    }
  }

  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required double amount,
    required DateTime date,
    required DateTime paidUntil,
  }) async {
    try {
      return await _service.createStudentPayment(
        studentId: studentId,
        body: CreateStudentPaymentRequest(
          amount: amount,
          date: date,
          paidUntil: paidUntil,
        ),
      );
    } on DioException catch (e) {
      throw Exception('Failed to create student payment: ${e.message}');
    }
  }

  /// Attaches [studentId] to [groupId], replacing the group the student
  /// belonged to before. `joinedAt` is the day the student joined the group.
  Future<void> assignStudentGroup({
    required String studentId,
    required String groupId,
    required DateTime joinedAt,
  }) async {
    try {
      await _service.updateStudent(
        studentId: studentId,
        body: <String, dynamic>{
          'groupId': groupId,
          'joinedAt': _isoDate.format(joinedAt),
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to assign the student to the group: ${e.message}',
      );
    }
  }

  void clearCache() {
    _cachedStudents = null;
  }
}
