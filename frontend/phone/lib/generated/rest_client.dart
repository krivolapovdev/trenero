// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'visit_controller/visit_controller_client.dart';
import 'transaction_controller/transaction_controller_client.dart';
import 'student_controller/student_controller_client.dart';
import 'reviewer_auth_controller/reviewer_auth_controller_client.dart';
import 'student_payment_controller/student_payment_controller_client.dart';
import 'o_auth_2_controller/o_auth_2_controller_client.dart';
import 'lesson_controller/lesson_controller_client.dart';
import 'jwt_token_controller/jwt_token_controller_client.dart';
import 'group_controller/group_controller_client.dart';
import 'metric_controller/metric_controller_client.dart';
import 'user_controller/user_controller_client.dart';

/// OpenAPI definition `vv0`
class RestClient {
  RestClient(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => 'v0';

  VisitControllerClient? _visitController;
  TransactionControllerClient? _transactionController;
  StudentControllerClient? _studentController;
  ReviewerAuthControllerClient? _reviewerAuthController;
  StudentPaymentControllerClient? _studentPaymentController;
  OAuth2ControllerClient? _oAuth2Controller;
  LessonControllerClient? _lessonController;
  JwtTokenControllerClient? _jwtTokenController;
  GroupControllerClient? _groupController;
  MetricControllerClient? _metricController;
  UserControllerClient? _userController;

  VisitControllerClient get visitController =>
      _visitController ??= VisitControllerClient(_dio, baseUrl: _baseUrl);

  TransactionControllerClient get transactionController =>
      _transactionController ??= TransactionControllerClient(
        _dio,
        baseUrl: _baseUrl,
      );

  StudentControllerClient get studentController =>
      _studentController ??= StudentControllerClient(_dio, baseUrl: _baseUrl);

  ReviewerAuthControllerClient get reviewerAuthController =>
      _reviewerAuthController ??= ReviewerAuthControllerClient(
        _dio,
        baseUrl: _baseUrl,
      );

  StudentPaymentControllerClient get studentPaymentController =>
      _studentPaymentController ??= StudentPaymentControllerClient(
        _dio,
        baseUrl: _baseUrl,
      );

  OAuth2ControllerClient get oAuth2Controller =>
      _oAuth2Controller ??= OAuth2ControllerClient(_dio, baseUrl: _baseUrl);

  LessonControllerClient get lessonController =>
      _lessonController ??= LessonControllerClient(_dio, baseUrl: _baseUrl);

  JwtTokenControllerClient get jwtTokenController =>
      _jwtTokenController ??= JwtTokenControllerClient(_dio, baseUrl: _baseUrl);

  GroupControllerClient get groupController =>
      _groupController ??= GroupControllerClient(_dio, baseUrl: _baseUrl);

  MetricControllerClient get metricController =>
      _metricController ??= MetricControllerClient(_dio, baseUrl: _baseUrl);

  UserControllerClient get userController =>
      _userController ??= UserControllerClient(_dio, baseUrl: _baseUrl);
}
