import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/lesson_response.dart';

final groupLessonsProvider =
    AsyncNotifierProvider.family<
      GroupLessonsController,
      List<LessonResponse>,
      String
    >(GroupLessonsController.new);

class GroupLessonsController extends AsyncNotifier<List<LessonResponse>> {
  new(this.groupId);

  final String groupId;

  @override
  Future<List<LessonResponse>> build() async {
    final from = DateTime(2000, 1, 1);
    final to = DateTime.now();

    await Future.delayed(Duration(seconds: 2));

    final repository = ref.watch(groupRepositoryProvider);
    return repository.getGroupLessons(groupId: groupId, from: from, to: to);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
