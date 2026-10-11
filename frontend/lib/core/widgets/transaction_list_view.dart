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
  static const double _loadMoreThreshold = 200;

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
    final onFetchNextPage = widget.onFetchNextPage;
    if (onFetchNextPage == null) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _loadMoreThreshold) {
      onFetchNextPage();
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

    final groupedTransactions = TransactionDateFormatter.groupTransactionsByDate(
      widget.transactions,
    );
    final sections = groupedTransactions.entries.toList();
    final footerCount = widget.isLoadingMore ? 1 : 0;

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        bottom: AppSpacing.xl,
      ),
      itemCount: sections.length + footerCount,
      itemBuilder: (context, index) {
        if (index >= sections.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = sections[index];

        return _TransactionDateSection(
          dateHeader: TransactionDateFormatter.formatDateHeader(entry.key),
          transactions: entry.value,
          overrideTitle: widget.overrideTitle,
          isLoading: widget.isLoading,
        );
      },
    );
  }
}

class _TransactionDateSection extends StatelessWidget {
  final String dateHeader;
  final List<TransactionResponse> transactions;
  final String? overrideTitle;
  final bool isLoading;

  const new({
    required this.dateHeader,
    required this.transactions,
    required this.isLoading,
    this.overrideTitle,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
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
            for (final transaction in transactions)
              TransactionTile(
                key: ValueKey(transaction.id),
                transaction: transaction,
                overrideTitle: overrideTitle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                borderRadius: BorderRadius.zero,
                onTap: isLoading
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionPage(
                            transaction: transaction,
                            overrideTitle: overrideTitle,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    ],
  );
}
