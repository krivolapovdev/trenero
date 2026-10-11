import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// The first load reaches back [monthsPerLoad] months from today, the current
/// month included. Stepping the calendar further back loads the next window of
/// months from the server instead of every lesson the student ever had, so the
/// first response stays small.
class StudentLessonsController
    extends AsyncNotifier<List<VisitWithLessonResponse>> {
  final String studentId;

  new(this.studentId);

  /// How many months a single load reaches across.
  static const int monthsPerLoad = 3;

  /// The first day of the earliest month that is loaded, `null` until the first
  /// load finished.
  DateTime? _loadedFrom;

  /// The last day that is loaded, `null` until the first load finished.
  DateTime? _loadedTo;

  /// Guards against loading another window while one is still in flight.
  bool _isLoading = false;

  /// The first day of the month [months] months before the month of [day].
  static DateTime firstDayOfMonthBefore(DateTime day, int months) =>
      DateTime(day.year, day.month - months);

  @override
  Future<List<VisitWithLessonResponse>> build() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final windowFrom = StudentLessonsController.firstDayOfMonthBefore(
      today,
      monthsPerLoad - 1,
    );

    // The calendars can show a month that lies before the window (the month
    // that is shown survives a reload of the lessons), so the window reaches
    // back to it instead of leaving it empty.
    final shownMonth = ref.read(studentLessonsMonthProvider(studentId));
    final from =
        _loadedFrom ??
        (shownMonth.isBefore(windowFrom) ? shownMonth : windowFrom);
    final to = _loadedTo ?? today;

    final visits = await _fetch(from, to);
    _loadedFrom = from;
    _loadedTo = to;

    return visits;
  }

  Future<List<VisitWithLessonResponse>> _fetch(DateTime from, DateTime to) =>
      ref
          .read(studentRepositoryProvider)
          .getStudentVisits(studentId: studentId, from: from, to: to);

  /// Loads the months before the loaded range until [month] is stored too.
  ///
  /// The calendar steps one month at a time, so a single window is usually
  /// enough; the loop keeps the promise when [month] lies further back. A month
  /// that is asked for while a window is still in flight is remembered and
  /// loaded by the window that is running, so a fast run back through the
  /// months cannot leave one of them empty. While a window is in flight the
  /// lessons that are already stored stay and
  /// [studentLessonsLoadingEarlierProvider] is set, so the calendar can shimmer
  /// over the month that was opened.
  Future<void> loadEarlierMonths(DateTime month) async {
    _rememberPendingMonth(month);

    if (_isLoading || !_hasPendingMonth) return;

    _isLoading = true;
    ref
        .read(studentLessonsLoadingEarlierProvider(studentId).notifier)
        .setLoading(true);

    // The lessons that are already stored, put back when a window fails.
    var current = state.value ?? const <VisitWithLessonResponse>[];

    try {
      while (_hasPendingMonth) {
        // The window ends the day before the loaded range starts, so no lesson
        // is stored twice.
        final from = StudentLessonsController.firstDayOfMonthBefore(
          _loadedFrom!,
          monthsPerLoad,
        );
        final to = _loadedFrom!.subtract(const Duration(days: 1));

        final earlier = await _fetch(from, to);

        current = [...earlier, ...current];
        state = AsyncData(current);
        _loadedFrom = from;
      }
    } catch (_) {
      // The lessons that are stored stay shown, the month can be opened again.
      state = AsyncData(current);
    } finally {
      _pendingMonth = null;
      ref
          .read(studentLessonsLoadingEarlierProvider(studentId).notifier)
          .setLoading(false);
      _isLoading = false;
    }
  }

  /// Remembers [month] as the month that still has to be loaded, keeping the
  /// earliest one that was asked for.
  void _rememberPendingMonth(DateTime month) {
    final pending = _pendingMonth;
    if (pending == null || _isBeforeMonth(month, pending)) {
      _pendingMonth = month;
    }
  }

  /// Whether a month that was asked for still lies before the loaded range.
  bool get _hasPendingMonth =>
      _loadedFrom != null &&
      _pendingMonth != null &&
      _isBeforeMonth(_pendingMonth!, _loadedFrom!);

  /// The earliest month that was asked for and is not loaded yet.
  DateTime? _pendingMonth;

  /// Whether [month] falls before [other], comparing the months only.
  static bool _isBeforeMonth(DateTime month, DateTime other) =>
      month.year < other.year ||
      (month.year == other.year && month.month < other.month);

  /// Drops the loaded months, opens the latest month and reads the last
  /// [monthsPerLoad] months again.
  ///
  /// The state goes through loading with no value, so the calendars shimmer
  /// instead of keeping the months that are no longer loaded.
  Future<void> refresh() async {
    _loadedFrom = null;
    _loadedTo = null;

    ref.read(studentLessonsMonthProvider(studentId).notifier).showLatest();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
