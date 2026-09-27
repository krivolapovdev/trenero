import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/providers/groups_providers.dart';
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
      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw ArgumentError('Group name is required.');
      }

      double? parsedPrice;
      if (priceText != null && priceText.trim().isNotEmpty) {
        parsedPrice = double.tryParse(priceText.trim());
        if (parsedPrice == null || parsedPrice < 0) {
          throw ArgumentError('Price must be a valid positive number.');
        }
      }

      final request = CreateGroupRequest(
        name: trimmedName,
        defaultPrice: parsedPrice,
        note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      );

      final client = ref.read(groupControllerClientProvider);
      await client.createGroup(body: request);
      await ref.read(groupsNotifierProvider.notifier).refreshGroups();
    });

    return !state.hasError;
  }
}
