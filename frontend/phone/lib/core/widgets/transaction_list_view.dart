import 'package:flutter/material.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/generated/models/transaction_response.dart';

class TransactionListView extends StatefulWidget {
  final List<TransactionResponse> transactions;
  final Future<void> Function() onRefresh;
  final VoidCallback? onFetchNextPage;
  final bool isLoadingMore;
  final String? overrideTitle;
  final String emptyText;

  const new({
    super.key,
    required this.transactions,
    required this.onRefresh,
    this.onFetchNextPage,
    this.isLoadingMore = false,
    this.overrideTitle,
    this.emptyText = 'Нет операций',
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onFetchNextPage != null &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      widget.onFetchNextPage!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return Center(
        child: Text(
          widget.emptyText,
          style: const TextStyle(color: Color(0xFF8E8E93)),
        ),
      );
    }

    final groupedTransactions =
        TransactionDateFormatter.groupTransactionsByDate(widget.transactions);

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
      children: [
        ...groupedTransactions.entries.expand((entry) {
          final dateHeader = TransactionDateFormatter.formatDateHeader(
            entry.key,
            context,
          );
          final items = entry.value;

          return [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ...items.map(
                    (tx) => TransactionTile(
                      transaction: tx,
                      overrideTitle: widget.overrideTitle,
                    ),
                  ),
                ],
              ),
            ),
          ];
        }),
        if (widget.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
