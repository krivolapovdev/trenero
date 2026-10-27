import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_form_values.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';

final createGroupControllerProvider =
    AsyncNotifierProvider<CreateGroupController, void>(
      CreateGroupController.new,
    );

class CreateGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<GroupSummaryResponse?> saveGroup({
    required String name,
    required String? priceText,
    required String? note,
  }) async {
    GroupResponse? createdGroup;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final values = validateGroupForm(
        name: name,
        priceText: priceText,
        note: note,
      );

      final request = CreateGroupRequest(
        name: values.name,
        defaultPrice: values.defaultPrice,
        note: values.note,
      );

      final repository = ref.read(groupRepositoryProvider);
      createdGroup = await repository.createGroup(request);

      refreshAfterGroupMutation(ref);
    });

    if (state.hasError || createdGroup == null) {
      return null;
    }

    final created = createdGroup!;
    final groups = ref.read(groupListControllerProvider).value;
    return groups?.where((g) => g.id == created.id).firstOrNull ??
        GroupSummaryResponse(
          id: created.id,
          name: created.name,
          createdAt: created.createdAt,
          defaultPrice: created.defaultPrice,
          note: created.note,
          countOfStudents: 0,
        );
  }
}
