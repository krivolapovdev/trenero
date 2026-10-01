// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/login_response.dart';

part 'reviewer_auth_controller_client.g.dart';

@RestApi()
abstract class ReviewerAuthControllerClient {
  factory ReviewerAuthControllerClient(Dio dio, {String? baseUrl}) =
      _ReviewerAuthControllerClient;

  @POST('/api/v1/reviewer/login')
  Future<LoginResponse> login({
    @Header('X-Reviewer-Key') required String xReviewerKey,
  });
}
