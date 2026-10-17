import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';

final groupServiceProvider = Provider<GroupControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return GroupControllerClient(api);
});
