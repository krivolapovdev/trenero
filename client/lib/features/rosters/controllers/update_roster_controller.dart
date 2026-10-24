import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';
import 'package:phone/generated/models/roster_response.dart';

final updateRosterControllerProvider =
    AsyncNotifierProvider<UpdateRosterController, RosterResponse?>(
      UpdateRosterController.new,
    );

class UpdateRosterController extends AsyncNotifier<RosterResponse?> {
  @override
  FutureOr<RosterResponse?> build() => null;

  Future<bool> updateRoster({
    required String rosterId,
    required String name,
    DateTime? rosterDate,
    String? note,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(rosterRepositoryProvider);
      final trimmedNote = note?.trim();
      final body = <String, dynamic>{
        'name': name.trim(),
        'date': rosterDate?.toUtc().toIso8601String(),
        'note': trimmedNote != null && trimmedNote.isNotEmpty
            ? trimmedNote
            : null,
      };

      final updated = await repository.updateRoster(
        rosterId: rosterId,
        body: body,
      );

      await ref
          .read(rosterListControllerProvider.notifier)
          .getAllRosters(forceRefresh: true);

      return updated;
    });

    return !state.hasError;
  }
}
