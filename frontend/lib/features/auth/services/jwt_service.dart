import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/jwt_controller/jwt_controller_client.dart';

final jwtServiceProvider = Provider<JwtControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return JwtControllerClient(api);
});
