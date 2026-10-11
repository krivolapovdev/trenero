import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';

class GroupListRetry extends ConsumerWidget {
  final Object? error;

  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: '$error',
    scrollable: true,
    onRetry: () => ref.read(groupListControllerProvider.notifier).getAllGroups(),
  );
}
