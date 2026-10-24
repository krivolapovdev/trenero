import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/rosters/repositories/roster_repository.dart';
import 'package:phone/generated/models/roster_response.dart';

final rosterListControllerProvider =
    AsyncNotifierProvider<RosterListController, List<RosterResponse>>(
      RosterListController.new,
    );

class RosterListController extends AsyncNotifier<List<RosterResponse>> {
  @override
  Future<List<RosterResponse>> build() async {
    final repository = ref.watch(rosterRepositoryProvider);
    return repository.getAllRosters(forceRefresh: true);
  }

  Future<void> getAllRosters({bool forceRefresh = false}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(rosterRepositoryProvider)
          .getAllRosters(forceRefresh: forceRefresh),
    );
  }
}
