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

final studentLessonsMonthProvider =
    NotifierProvider.family<StudentLessonsMonthController, DateTime, String>(
      StudentLessonsMonthController.new,
    );

class StudentLessonsMonthController extends Notifier<DateTime> {
  final String studentId;

  new(this.studentId);

  static DateTime get latestMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  DateTime build() => latestMonth;

  void show(DateTime month) => state = month;

  void showLatest() => state = latestMonth;
}

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

  void setLoading(bool isLoading) => state = isLoading;
}

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
