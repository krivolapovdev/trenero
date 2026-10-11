import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';

final lessonServiceProvider = Provider<LessonControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return LessonControllerClient(api);
});
