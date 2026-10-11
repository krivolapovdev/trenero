import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/reviewer_auth_controller/reviewer_auth_controller_client.dart';

/// The reviewer login is a public endpoint, so it uses the anonymous client.
final reviewerAuthServiceProvider = Provider<ReviewerAuthControllerClient>((
  ref,
) {
  final api = ref.watch(unauthenticatedDioProvider);
  return ReviewerAuthControllerClient(api);
});
