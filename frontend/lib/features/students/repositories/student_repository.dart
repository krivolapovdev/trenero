import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/student_response.dart';
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

  new(this._service);

  Future<List<StudentSummaryResponse>> getAllStudents({
    bool forceRefresh = false,
  }) async {
    final cached = _cachedStudents;

    if (!forceRefresh && cached != null) {
      return List.unmodifiable(cached);
    }

    return guardApiCall(() async {
      final students = await _service.getStudentsSummary();
      _cachedStudents = students;

      return List.unmodifiable(students);
    });
  }

  Future<StudentResponse> createStudent(CreateStudentRequest request) =>
      guardApiCall(() => _service.createStudent(body: request));

  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => guardApiCall(
    () => _service.updateStudent(studentId: studentId, body: body),
  );

  Future<void> deleteStudent(String studentId) => guardApiCall(() async {
    await _service.deleteStudent(studentId: studentId);

    final cached = _cachedStudents;

    if (cached != null) {
      _cachedStudents = cached
          .where((student) => student.id != studentId)
          .toList();
    }
  });

  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    required DateTime from,
    required DateTime to,
  }) => guardApiCall(
    () => _service.getStudentVisits(studentId: studentId, from: from, to: to),
  );

  Future<List<TransactionResponse>> getStudentPayments(String studentId) =>
      guardApiCall(() => _service.getStudentPayments(studentId: studentId));

  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required double amount,
    required DateTime date,
    required DateTime paidUntil,
  }) => guardApiCall(
    () => _service.createStudentPayment(
      studentId: studentId,
      body: CreateStudentPaymentRequest(
        amount: amount,
        date: date,
        paidUntil: paidUntil,
      ),
    ),
  );

  Future<void> assignStudentGroups({
    required String studentId,
    required Set<String> groupIds,
  }) => guardApiCall(
    () => _service.updateStudent(
      studentId: studentId,
      body: <String, dynamic>{'groupIds': groupIds.toList()},
    ),
  );

  void clearCache() {
    _cachedStudents = null;
  }
}
