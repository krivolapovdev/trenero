import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

final studentServiceProvider = Provider<StudentControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return StudentControllerClient(api);
});
