import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/finance/models/transaction_period_filter.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';

TransactionResponse _transaction(DateTime date) => TransactionResponse(
  id: 'transaction-${date.toIso8601String()}',
  amount: 100,
  date: date,
  type: TransactionType.income,
  createdAt: date,
);

void main() {
  group('isEmpty', () {
    test('is empty when no bound is selected', () {
      expect(const TransactionPeriodFilter().isEmpty, isTrue);
    });

    test('is not empty when at least one bound is selected', () {
      expect(
        TransactionPeriodFilter(start: DateTime(2026, 9, 16)).isNotEmpty,
        isTrue,
      );
      expect(
        TransactionPeriodFilter(end: DateTime(2026, 10, 13)).isNotEmpty,
        isTrue,
      );
    });
  });

  group('matches', () {
    final period = TransactionPeriodFilter(
      start: DateTime(2026, 9, 16),
      end: DateTime(2026, 10, 13),
    );

    test('includes both bounds', () {
      expect(period.matches(DateTime(2026, 9, 16)), isTrue);
      expect(period.matches(DateTime(2026, 10, 13)), isTrue);
    });

    test('ignores the time part of the day', () {
      expect(period.matches(DateTime(2026, 9, 16, 23, 59)), isTrue);
      expect(period.matches(DateTime(2026, 10, 13, 0, 1)), isTrue);
    });

    test('excludes the days outside the period', () {
      expect(period.matches(DateTime(2026, 9, 15)), isFalse);
      expect(period.matches(DateTime(2026, 10, 14)), isFalse);
    });

    test('supports an open ended period', () {
      final from = TransactionPeriodFilter(start: DateTime(2026, 9, 16));
      final until = TransactionPeriodFilter(end: DateTime(2026, 10, 13));

      expect(from.matches(DateTime(2030, 1, 1)), isTrue);
      expect(from.matches(DateTime(2026, 9, 15)), isFalse);
      expect(until.matches(DateTime(2020, 1, 1)), isTrue);
      expect(until.matches(DateTime(2026, 10, 14)), isFalse);
    });
  });

  group('filter', () {
    final transactions = [
      _transaction(DateTime(2026, 9, 15)),
      _transaction(DateTime(2026, 9, 16)),
      _transaction(DateTime(2026, 10, 14)),
    ];

    test('keeps every transaction when the period is empty', () {
      expect(
        const TransactionPeriodFilter().filter(transactions),
        same(transactions),
      );
    });

    test('keeps only the transactions of the period', () {
      final result = TransactionPeriodFilter(
        start: DateTime(2026, 9, 16),
        end: DateTime(2026, 10, 13),
      ).filter(transactions);

      expect(result, hasLength(1));
      expect(result.single.date, DateTime(2026, 9, 16));
    });
  });

  test('sameAs compares both bounds', () {
    final period = TransactionPeriodFilter(
      start: DateTime(2026, 9, 16),
      end: DateTime(2026, 10, 13),
    );

    expect(
      period.sameAs(
        TransactionPeriodFilter(
          start: DateTime(2026, 9, 16),
          end: DateTime(2026, 10, 13),
        ),
      ),
      isTrue,
    );
    expect(period.sameAs(const TransactionPeriodFilter()), isFalse);
    expect(
      period.sameAs(
        TransactionPeriodFilter(
          start: DateTime(2026, 9, 17),
          end: DateTime(2026, 10, 13),
        ),
      ),
      isFalse,
    );
  });
}
