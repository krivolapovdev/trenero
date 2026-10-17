import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionsRetry extends ConsumerWidget {
  final Object? error;

  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: error.userMessage(context.t),
    messageColor: Theme.of(context).colorScheme.error,
    scrollable: true,
    onRetry: () => ref.read(transactionsControllerProvider.notifier).refresh(),
  );
}
