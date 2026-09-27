import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/o_auth_2_controller/o_auth_2_controller_client.dart';

final oAuth2Service = Provider<OAuth2ControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return OAuth2ControllerClient(api);
});
