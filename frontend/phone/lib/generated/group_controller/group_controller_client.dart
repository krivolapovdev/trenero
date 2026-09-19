// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_group_request.dart';
import '../models/group_details_response.dart';
import '../models/group_overview_response.dart';
import '../models/group_response.dart';

part 'group_controller_client.g.dart';

@RestApi()
abstract class GroupControllerClient {
  factory GroupControllerClient(Dio dio, {String? baseUrl}) =
      _GroupControllerClient;

  @GET('/api/v1/groups')
  Future<List<GroupResponse>> getGroups();

  @POST('/api/v1/groups')
  Future<GroupResponse> createGroup({@Body() required CreateGroupRequest body});

  @GET('/api/v1/groups/{groupId}')
  Future<GroupResponse> getGroup({@Path('groupId') required String groupId});

  @DELETE('/api/v1/groups/{groupId}')
  Future<void> deleteGroup({@Path('groupId') required String groupId});

  @PATCH('/api/v1/groups/{groupId}')
  Future<GroupResponse> updateGroup({
    @Path('groupId') required String groupId,
    @Body() required Map<String, dynamic> body,
  });

  @GET('/api/v1/groups/{groupId}/details')
  Future<GroupDetailsResponse> getGroupDetails({
    @Path('groupId') required String groupId,
  });

  @GET('/api/v1/groups/overview')
  Future<List<GroupOverviewResponse>> getGroupsOverview();
}
