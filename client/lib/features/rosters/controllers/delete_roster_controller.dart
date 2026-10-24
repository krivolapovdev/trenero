import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';

final deleteRosterControllerProvider =
    AsyncNotifierProvider<DeleteRosterController, void>(
      DeleteRosterController.new,
    );

class DeleteRosterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteRoster(String rosterId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(rosterRepositoryProvider).deleteRoster(rosterId);

      await ref
          .read(rosterListControllerProvider.notifier)
          .getAllRosters(forceRefresh: true);
    });

    return !state.hasError;
  }
}
