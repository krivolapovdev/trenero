import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/group_response.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final client = ref.watch(groupServiceProvider);
  return GroupRepository(client);
});

class GroupRepository {
  final GroupControllerClient _client;

  new(this._client);

  Future<List<GroupResponse>> getAllGroups() async {
    try {
      return await _client.getAllGroups();
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }
}
