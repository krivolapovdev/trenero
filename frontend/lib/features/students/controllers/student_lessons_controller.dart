import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/controllers/month_window_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/export.dart';

final studentLessonsProvider =
    AsyncNotifierProvider.family<
      StudentLessonsController,
      List<VisitWithLessonResponse>,
      String
    >(StudentLessonsController.new);

/// The month the calendars of a student show.
///
/// It lives next to the lessons so that reloading them (the pull to refresh of
/// the student page) can open the latest month again.
final studentLessonsMonthProvider =
    NotifierProvider.family<StudentLessonsMonthController, DateTime, String>(
      StudentLessonsMonthController.new,
    );

class StudentLessonsMonthController extends Notifier<DateTime> {
  final String studentId;

  new(this.studentId);

  /// The current month, the latest month the calendars may show.
  static DateTime get latestMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  DateTime build() => latestMonth;

  /// Shows [month] on every calendar of the student.
  void show(DateTime month) => state = month;

  /// Opens the latest month, the one a reloaded set of lessons reaches back
  /// from.
  void showLatest() => state = latestMonth;
}

/// Whether the lessons of a student are loading months before the loaded range.
///
/// The lessons that are already stored stay in [studentLessonsProvider] while
/// that happens, so the calendars keep their blocks and the section shimmers
/// over them instead of dropping them.
final studentLessonsLoadingEarlierProvider =
    NotifierProvider.family<
      StudentLessonsLoadingEarlierController,
      bool,
      String
    >(StudentLessonsLoadingEarlierController.new);

class StudentLessonsLoadingEarlierController extends Notifier<bool> {
  final String studentId;

  new(this.studentId);

  @override
  bool build() => false;

  /// Marks the older months as loading, or as done.
  void setLoading(bool isLoading) => state = isLoading;
}

/// The lessons of a student, loaded a few months at a time.
///
/// The first load reaches back [MonthWindowController.monthsPerLoad] months
/// from today, the current month included. Stepping the calendars further back
/// loads the next window of months from the server instead of every lesson the
/// student ever had, so the first response stays small.
class StudentLessonsController
    extends MonthWindowController<VisitWithLessonResponse> {
  final String studentId;

  new(this.studentId);

  @override
  Future<List<VisitWithLessonResponse>> fetch(DateTime from, DateTime to) => ref
      .read(studentRepositoryProvider)
      .getStudentVisits(studentId: studentId, from: from, to: to);

  @override
  DateTime shownMonth() => ref.read(studentLessonsMonthProvider(studentId));

  @override
  void setLoadingEarlier(bool isLoading) => ref
      .read(studentLessonsLoadingEarlierProvider(studentId).notifier)
      .setLoading(isLoading);

  @override
  void showLatestMonth() =>
      ref.read(studentLessonsMonthProvider(studentId).notifier).showLatest();
}
