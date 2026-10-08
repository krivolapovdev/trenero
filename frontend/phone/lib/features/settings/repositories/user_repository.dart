import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/settings/services/user_service.dart';
import 'package:phone/generated/user_controller/user_controller_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserRepository(service);
});

class UserRepository {
  final UserControllerClient _client;

  new(this._client);

  Future<void> deleteAccount() async => await _client.deleteMyAccount();
}
