import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_form_values.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/create_group_request.dart';

final createGroupControllerProvider =
    AsyncNotifierProvider<CreateGroupController, void>(
      CreateGroupController.new,
    );

class CreateGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> saveGroup({
    required String name,
    required String? priceText,
    required String? note,
  }) async {
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
      await repository.createGroup(request);

      refreshAfterGroupMutation(ref);
    });

    return !state.hasError;
  }
}
