// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_student_payment_request.dart';
import '../models/student_payment_response.dart';
import '../models/update_payment_request.dart';

part 'student_payment_controller_client.g.dart';

@RestApi()
abstract class StudentPaymentControllerClient {
  factory StudentPaymentControllerClient(Dio dio, {String? baseUrl}) =
      _StudentPaymentControllerClient;

  @GET('/api/v1/payments')
  Future<List<StudentPaymentResponse>> getPayments();

  @POST('/api/v1/payments')
  Future<StudentPaymentResponse> createPayment({
    @Body() required CreateStudentPaymentRequest body,
  });

  @GET('/api/v1/payments/{paymentId}')
  Future<StudentPaymentResponse> getPayment({
    @Path('paymentId') required String paymentId,
  });

  @DELETE('/api/v1/payments/{paymentId}')
  Future<void> deletePayment({@Path('paymentId') required String paymentId});

  @PATCH('/api/v1/payments/{paymentId}')
  Future<StudentPaymentResponse> updatePayment({
    @Path('paymentId') required String paymentId,
    @Body() required UpdatePaymentRequest body,
  });
}
