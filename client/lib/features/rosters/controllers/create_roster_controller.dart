import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/controllers/roster_list_controller.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';
import 'package:phone/generated/models/create_roster_request.dart';
import 'package:phone/generated/models/roster_response.dart';

final createRosterControllerProvider =
    AsyncNotifierProvider<CreateRosterController, RosterResponse?>(
      CreateRosterController.new,
    );

class CreateRosterController extends AsyncNotifier<RosterResponse?> {
  @override
  FutureOr<RosterResponse?> build() => null;

  Future<bool> saveRoster({
    required String name,
    DateTime? date,
    String? note,
    List<String>? studentIds,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(rosterRepositoryProvider);
      final trimmedNote = note?.trim();
      final validStudentIds = studentIds != null && studentIds.isNotEmpty
          ? studentIds
          : null;
      final roster = await repository.createRoster(
        CreateRosterRequest(
          name: name.trim(),
          date: date?.toUtc(),
          note: trimmedNote != null && trimmedNote.isNotEmpty
              ? trimmedNote
              : null,
          studentIds: validStudentIds,
        ),
      );

      await ref
          .read(rosterListControllerProvider.notifier)
          .getAllRosters(forceRefresh: true);

      return roster;
    });

    return !state.hasError;
  }
}
