import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/auth/providers/auth_notifier.dart';
import 'package:phone/features/auth/repository/auth_repository.dart';

final reviewerAuthControllerProvider =
    AsyncNotifierProvider<ReviewerAuthController, void>(
      ReviewerAuthController.new,
    );

/// Logs in with the reviewer key from the auth page.
class ReviewerAuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Returns `true` when the key was accepted and the session was started.
  Future<bool> login(String reviewerKey) async {
    final trimmedKey = reviewerKey.trim();

    if (trimmedKey.isEmpty) {
      return false;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .authenticateReviewerKeyWithBackend(trimmedKey);
    });

    if (state.hasError) {
      return false;
    }

    ref.read(authNotifierProvider.notifier).markAuthenticated();

    return true;
  }
}
