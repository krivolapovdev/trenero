import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';

final transactionServiceProvider = Provider<TransactionControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return TransactionControllerClient(api);
});
