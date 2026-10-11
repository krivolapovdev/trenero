import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_form_values.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/services/group_service.dart';

final updateGroupControllerProvider =
    AsyncNotifierProvider<UpdateGroupController, void>(
      UpdateGroupController.new,
    );

class UpdateGroupController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> updateGroup({
    required String groupId,
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

      final body = <String, dynamic>{
        'name': values.name,
        'defaultPrice': values.defaultPrice,
        'note': values.note,
      };

      final service = ref.read(groupServiceProvider);
      await service.updateGroup(groupId: groupId, body: body);

      refreshAfterGroupMutation(ref);
    });

    return !state.hasError;
  }
}
