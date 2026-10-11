import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionListView extends StatefulWidget {
  final List<TransactionResponse> transactions;
  final Future<void> Function() onRefresh;
  final VoidCallback? onFetchNextPage;
  final bool isLoadingMore;
  final bool isLoading;
  final String? overrideTitle;
  final String? emptyText;

  const new({
    super.key,
    required this.transactions,
    required this.onRefresh,
    this.onFetchNextPage,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.overrideTitle,
    this.emptyText,
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
          widget.emptyText ?? context.t.noTransactions,
          style: const TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    final groupedTransactions =
        TransactionDateFormatter.groupTransactionsByDate(widget.transactions);

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      children: [
        ...groupedTransactions.entries.expand((entry) {
          final dateHeader = TransactionDateFormatter.formatDateHeader(
            entry.key,
          );
          final items = entry.value;

          return [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                dateHeader,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      borderRadius: BorderRadius.zero,
                      onTap: widget.isLoading
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TransactionPage(
                                  transaction: tx,
                                  overrideTitle: widget.overrideTitle,
                                ),
                              ),
                            ),
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
