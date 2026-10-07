import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      final body = <String, dynamic>{
        'name': trimmedName,
        'defaultPrice': parsedPrice,
        'note': note?.trim().isEmpty ?? true ? null : note!.trim(),
      };

      final service = ref.read(groupServiceProvider);
      await service.updateGroup(groupId: groupId, body: body);
    });

    return !state.hasError;
  }
}
