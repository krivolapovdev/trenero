import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/auth/controllers/auth_controller.dart';
import 'package:phone/features/settings/repositories/user_repository.dart';

final deleteAccountControllerProvider =
    AsyncNotifierProvider<DeleteAccountController, void>(
      DeleteAccountController.new,
    );

class DeleteAccountController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).deleteAccount();

      await ref.read(authControllerProvider.notifier).logout();
    });

    return !state.hasError;
  }
}
