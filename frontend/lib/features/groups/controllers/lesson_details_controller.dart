import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/generated/models/lesson_details_response.dart';

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
  Future<LessonDetailsResponse> build() {
    final service = ref.watch(lessonServiceProvider);

    return guardApiCall(() => service.getLessonDetails(lessonId: lessonId));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }
}
