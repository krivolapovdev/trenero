import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/controllers/month_window_controller.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/models/lesson_response.dart';

final groupLessonsProvider =
    AsyncNotifierProvider.family<
      GroupLessonsController,
      List<LessonResponse>,
      String
    >(GroupLessonsController.new);

final groupLessonsMonthProvider =
    NotifierProvider.family<GroupLessonsMonthController, DateTime, String>(
      GroupLessonsMonthController.new,
    );

class GroupLessonsMonthController extends Notifier<DateTime> {
  final String groupId;

  new(this.groupId);

  static DateTime get latestMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  DateTime build() => latestMonth;

  void show(DateTime day) => state = DateTime(day.year, day.month);

  void showLatest() => state = latestMonth;
}

final groupLessonsLoadingEarlierProvider =
    NotifierProvider.family<GroupLessonsLoadingEarlierController, bool, String>(
      GroupLessonsLoadingEarlierController.new,
    );

class GroupLessonsLoadingEarlierController extends Notifier<bool> {
  final String groupId;

  new(this.groupId);

  @override
  bool build() => false;

  void setLoading(bool isLoading) => state = isLoading;
}

class GroupLessonsController extends MonthWindowController<LessonResponse> {
  new(this.groupId);

  final String groupId;

  @override
  Future<List<LessonResponse>> fetch(DateTime from, DateTime to) => ref
      .read(groupRepositoryProvider)
      .getGroupLessons(groupId: groupId, from: from, to: to);

  @override
  DateTime shownMonth() => ref.read(groupLessonsMonthProvider(groupId));

  @override
  void setLoadingEarlier(bool isLoading) => ref
      .read(groupLessonsLoadingEarlierProvider(groupId).notifier)
      .setLoading(isLoading);

  @override
  void showLatestMonth() =>
      ref.read(groupLessonsMonthProvider(groupId).notifier).showLatest();
}
