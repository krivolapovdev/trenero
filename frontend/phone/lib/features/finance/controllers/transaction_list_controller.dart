import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/repositories/transaction_repository.dart';
import 'package:phone/generated/models/transaction_response.dart';

class TransactionsState {
  final List<TransactionResponse> transactions;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const new({
    this.transactions = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  TransactionsState copyWith({
    List<TransactionResponse>? transactions,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => TransactionsState(
    transactions: transactions ?? this.transactions,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

final transactionsControllerProvider =
    AsyncNotifierProvider<TransactionsController, TransactionsState>(
      TransactionsController.new,
    );

class TransactionsController extends AsyncNotifier<TransactionsState> {
  static const int _pageSize = 15;

  @override
  FutureOr<TransactionsState> build() async {
    final repository = ref.read(transactionRepositoryProvider);
    final response = await repository.getTransactionsByPage(
      page: 1,
      size: _pageSize,
    );
    final content = response.content ?? [];

    return TransactionsState(
      transactions: content,
      page: 1,
      hasMore: content.length >= _pageSize,
    );
  }

  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final nextPage = currentState.page + 1;
      final response = await repository.getTransactionsByPage(
        page: nextPage,
        size: _pageSize,
      );
      final content = response.content ?? [];

      await Future.delayed(Duration(seconds: 2));

      state = AsyncData(
        currentState.copyWith(
          transactions: [...currentState.transactions, ...content],
          page: nextPage,
          hasMore: content.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      final response = await repository.getTransactionsByPage(
        page: 1,
        size: _pageSize,
      );
      final content = response.content ?? [];

      await Future.delayed(Duration(seconds: 2));

      return TransactionsState(
        transactions: content,
        page: 1,
        hasMore: content.length >= _pageSize,
      );
    });
  }
}
