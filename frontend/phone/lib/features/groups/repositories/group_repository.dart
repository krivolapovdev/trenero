import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/group_summary.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final service = ref.watch(groupServiceProvider);
  return GroupRepository(service);
});

class GroupRepository {
  final GroupControllerClient _service;

  new(this._service);

  Future<List<GroupSummary>> getAllGroups() async {
    try {
      return await _service.getAllGroupsSummary();
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    }
  }
}
