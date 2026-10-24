import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/roster_controller/roster_controller_client.dart';

final rosterServiceProvider = Provider<RosterControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return RosterControllerClient(api);
});
