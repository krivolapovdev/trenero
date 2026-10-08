import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/generated/models/lesson_details_response.dart';

/// The lesson itself plus the visits of its students.
final lessonDetailsProvider =
    AsyncNotifierProvider.family<
      LessonDetailsController,
      LessonDetailsResponse,
      String
    >(LessonDetailsController.new);

class LessonDetailsController extends AsyncNotifier<LessonDetailsResponse> {
  new(this.lessonId);

  final String lessonId;

  @override
  Future<LessonDetailsResponse> build() =>
      ref.watch(lessonServiceProvider).getLessonDetails(lessonId: lessonId);

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
