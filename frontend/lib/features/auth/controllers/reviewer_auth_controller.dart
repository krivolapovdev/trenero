import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/auth/controllers/auth_controller.dart';
import 'package:phone/features/auth/repository/auth_repository.dart';

final reviewerAuthControllerProvider =
    AsyncNotifierProvider<ReviewerAuthController, void>(
      ReviewerAuthController.new,
    );

class ReviewerAuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

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

    ref.read(authControllerProvider.notifier).markAuthenticated();

    return true;
  }
}
