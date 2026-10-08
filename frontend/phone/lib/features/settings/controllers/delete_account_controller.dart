import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/auth/providers/auth_notifier.dart';
import 'package:phone/features/settings/repositories/user_repository.dart';

final deleteAccountControllerProvider =
    AsyncNotifierProvider<DeleteAccountController, void>(
      DeleteAccountController.new,
    );

class DeleteAccountController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Deletes the account of the current user and closes the session.
  Future<bool> deleteAccount() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).deleteAccount();

      // The backend removed the user, so the stored tokens are not usable
      // anymore.
      await ref.read(authNotifierProvider.notifier).logout();
    });

    return !state.hasError;
  }
}
