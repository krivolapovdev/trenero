import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/group_overview_response.dart';

final groupControllerClientProvider = Provider<GroupControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return GroupControllerClient(api);
});

final groupsNotifierProvider = NotifierProvider<GroupsNotifier, GroupsState>(
  GroupsNotifier.new,
);

class GroupsState {
  final Map<String, dynamic> allGroups;
  final bool isRefreshing;
  final String? error;

  const new({this.allGroups = const {}, this.isRefreshing = false, this.error});

  GroupsState copyWith({
    Map<String, dynamic>? allGroups,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) => GroupsState(
    allGroups: allGroups ?? this.allGroups,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: clearError ? null : (error ?? this.error),
  );
}

class GroupsNotifier extends Notifier<GroupsState> {
  late final GroupControllerClient _client;

  @override
  GroupsState build() {
    _client = ref.watch(groupControllerClientProvider);
    return const GroupsState();
  }

  void setAllGroups(List<GroupOverviewResponse> groups) {
    final groupsMap = {for (final g in groups) g.id: g};

    state = state.copyWith(allGroups: groupsMap);
  }

  Future<void> refreshGroups() async {
    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      final data = await _client.getGroupsOverview();
      setAllGroups(data);
    } catch (e) {
      state = state.copyWith(error: _extractErrorMessage(e));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  void addGroup(dynamic group) {
    final updatedMap = Map<String, dynamic>.from(state.allGroups);
    updatedMap[group.id] = group;

    state = state.copyWith(allGroups: updatedMap);
  }

  void updateGroup(String id, dynamic updatedGroup) {
    if (!state.allGroups.containsKey(id)) return;

    final updatedMap = Map<String, dynamic>.from(state.allGroups);
    updatedMap[id] = updatedGroup;

    state = state.copyWith(allGroups: updatedMap);
  }

  void removeGroup(String id) {
    final updatedMap = Map<String, dynamic>.from(state.allGroups);
    updatedMap.remove(id);

    state = state.copyWith(allGroups: updatedMap);
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      return error.response?.data?['message']?.toString() ??
          error.message ??
          'An unexpected network error occurred';
    }
    return error.toString();
  }
}
