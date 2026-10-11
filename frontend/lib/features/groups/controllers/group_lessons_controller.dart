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

/// The month the calendar of a group shows.
///
/// It lives next to the lessons so that reloading them (the pull to refresh of
/// the group page) can open the latest month again.
final groupLessonsMonthProvider =
    NotifierProvider.family<GroupLessonsMonthController, DateTime, String>(
      GroupLessonsMonthController.new,
    );

class GroupLessonsMonthController extends Notifier<DateTime> {
  final String groupId;

  new(this.groupId);

  /// The current month, the latest month the calendar may show.
  static DateTime get latestMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  DateTime build() => latestMonth;

  /// Shows the month of [day] on the calendar.
  void show(DateTime day) => state = DateTime(day.year, day.month);

  /// Opens the latest month, the one a reloaded set of lessons reaches back
  /// from.
  void showLatest() => state = latestMonth;
}

/// Whether the lessons of a group are loading months before the loaded range.
///
/// The lessons that are already stored stay in [groupLessonsProvider] while
/// that happens, so the calendar keeps its blocks and the section shimmers over
/// them instead of dropping them.
final groupLessonsLoadingEarlierProvider =
    NotifierProvider.family<GroupLessonsLoadingEarlierController, bool, String>(
      GroupLessonsLoadingEarlierController.new,
    );

class GroupLessonsLoadingEarlierController extends Notifier<bool> {
  final String groupId;

  new(this.groupId);

  @override
  bool build() => false;

  /// Marks the older months as loading, or as done.
  void setLoading(bool isLoading) => state = isLoading;
}

/// The lessons of a group, loaded a few months at a time.
///
/// The first load reaches back [MonthWindowController.monthsPerLoad] months
/// from today, the current month included. Stepping the calendar further back
/// loads the next window of months from the server instead of every lesson the
/// group ever had, so the first response stays small.
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
