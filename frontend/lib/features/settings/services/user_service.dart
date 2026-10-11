import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/user_controller/user_controller_client.dart';

final userServiceProvider = Provider<UserControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return UserControllerClient(api);
});
