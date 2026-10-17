import 'package:phone/generated/models/transaction_response.dart';

class TransactionPeriodFilter {
  final DateTime? start;
  final DateTime? end;

  const new({this.start, this.end});

  bool get isEmpty => start == null && end == null;

  bool get isNotEmpty => !isEmpty;

  bool sameAs(TransactionPeriodFilter other) =>
      start == other.start && end == other.end;

  bool matches(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final from = start;
    final to = end;

    if (from != null && day.isBefore(from)) return false;
    if (to != null && day.isAfter(to)) return false;

    return true;
  }

  List<TransactionResponse> filter(List<TransactionResponse> transactions) =>
      isEmpty
      ? transactions
      : transactions.where((transaction) => matches(transaction.date)).toList();
}
