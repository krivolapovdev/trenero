import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/reviewer_auth_controller/reviewer_auth_controller_client.dart';

final reviewerAuthServiceProvider = Provider<ReviewerAuthControllerClient>((
  ref,
) {
  final api = ref.watch(unauthenticatedDioProvider);
  return ReviewerAuthControllerClient(api);
});
