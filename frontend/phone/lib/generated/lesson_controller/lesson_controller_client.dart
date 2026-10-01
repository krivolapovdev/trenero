// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_lesson_request.dart';
import '../models/lesson_details_response.dart';
import '../models/lesson_response.dart';
import '../models/update_lesson_request.dart';

part 'lesson_controller_client.g.dart';

@RestApi()
abstract class LessonControllerClient {
  factory LessonControllerClient(Dio dio, {String? baseUrl}) =
      _LessonControllerClient;

  @GET('/api/v1/lessons')
  Future<List<LessonResponse>> getLessons();

  @POST('/api/v1/lessons')
  Future<LessonResponse> createLesson({
    @Body() required CreateLessonRequest body,
  });

  @GET('/api/v1/lessons/{lessonId}')
  Future<LessonResponse> getLesson({
    @Path('lessonId') required String lessonId,
  });

  @DELETE('/api/v1/lessons/{lessonId}')
  Future<void> deleteLesson({@Path('lessonId') required String lessonId});

  @PATCH('/api/v1/lessons/{lessonId}')
  Future<LessonResponse> updateLesson({
    @Path('lessonId') required String lessonId,
    @Body() required UpdateLessonRequest body,
  });

  @GET('/api/v1/lessons/{lessonId}/details')
  Future<LessonDetailsResponse> getLessonDetails({
    @Path('lessonId') required String lessonId,
  });
}
