import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/models/transaction_period_filter.dart';

final transactionFilterControllerProvider =
    NotifierProvider<TransactionFilterController, TransactionPeriodFilter>(
      TransactionFilterController.new,
    );

class TransactionFilterController extends Notifier<TransactionPeriodFilter> {
  @override
  TransactionPeriodFilter build() => const TransactionPeriodFilter();

  void setPeriod(TransactionPeriodFilter period) => state = period;

  void clear() => state = const TransactionPeriodFilter();
}
