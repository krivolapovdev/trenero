// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_visit_request.dart';
import '../models/visit_response.dart';

part 'visit_controller_client.g.dart';

@RestApi()
abstract class VisitControllerClient {
  factory VisitControllerClient(Dio dio, {String? baseUrl}) =
      _VisitControllerClient;

  @GET('/api/v1/visits')
  Future<List<VisitResponse>> getVisits();

  @POST('/api/v1/visits')
  Future<VisitResponse> createVisit({@Body() required CreateVisitRequest body});

  @GET('/api/v1/visits/{visitId}')
  Future<VisitResponse> getVisit({@Path('visitId') required String visitId});

  @DELETE('/api/v1/visits/{visitId}')
  Future<void> deleteVisit({@Path('visitId') required String visitId});

  @PATCH('/api/v1/visits/{visitId}')
  Future<VisitResponse> updateVisit({
    @Path('visitId') required String visitId,
    @Body() required Map<String, dynamic> body,
  });
}
