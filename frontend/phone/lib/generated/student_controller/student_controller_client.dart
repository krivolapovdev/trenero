// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_student_request.dart';
import '../models/student_response.dart';
import '../models/student_summary_response.dart';
import '../models/transaction_response.dart';
import '../models/visit_with_lesson_response.dart';

part 'student_controller_client.g.dart';

@RestApi()
abstract class StudentControllerClient {
  factory StudentControllerClient(Dio dio, {String? baseUrl}) =
      _StudentControllerClient;

  @GET('/api/v1/students')
  Future<List<StudentResponse>> getStudents();

  @POST('/api/v1/students')
  Future<StudentResponse> createStudent({
    @Body() required CreateStudentRequest body,
  });

  @GET('/api/v1/students/{studentId}')
  Future<StudentResponse> getStudent({
    @Path('studentId') required String studentId,
  });

  @DELETE('/api/v1/students/{studentId}')
  Future<void> deleteStudent({@Path('studentId') required String studentId});

  @PATCH('/api/v1/students/{studentId}')
  Future<StudentResponse> updateStudent({
    @Path('studentId') required String studentId,
    @Body() required Map<String, dynamic> body,
  });

  @GET('/api/v1/students/{studentId}/visits')
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    @Path('studentId') required String studentId,
  });

  @GET('/api/v1/students/{studentId}/payments')
  Future<List<TransactionResponse>> getStudentPayments({
    @Path('studentId') required String studentId,
  });

  @GET('/api/v1/students/overview')
  Future<List<StudentSummaryResponse>> getStudentsSummary();
}
