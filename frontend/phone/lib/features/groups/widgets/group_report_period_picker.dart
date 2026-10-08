import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/providers/language_provider.dart';

/// The year and month popup buttons shown above the group report table.
class GroupReportPeriodPicker extends ConsumerWidget {
  static const List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  final int year;
  final int month;
  final List<int> years;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const new({
    super.key,
    required this.year,
    required this.month,
    required this.years,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider).value?.languageCode;

    String monthLabel(int value) =>
        DateFormat.MMMM(locale).format(DateTime(year, value));

    return Row(
      children: [
        _PeriodButton<int>(
          value: year,
          values: years,
          label: '$year',
          labelBuilder: (value) => '$value',
          onSelected: onYearChanged,
        ),
        const SizedBox(width: 12),
        _PeriodButton<int>(
          value: month,
          values: months,
          label: monthLabel(month),
          labelBuilder: monthLabel,
          onSelected: onMonthChanged,
        ),
      ],
    );
  }
}

/// A popup menu button that shows the selected value in its label.
class _PeriodButton<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String label;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  const new({
    super.key,
    required this.value,
    required this.values,
    required this.label,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<T>(
      tooltip: '',
      initialValue: value,
      onSelected: onSelected,
      color: colorScheme.surface,
      itemBuilder: (menuContext) => [
        for (final item in values)
          PopupMenuItem<T>(
            value: item,
            child: Text(
              labelBuilder(item),
              style: TextStyle(
                fontWeight: item == value ? FontWeight.w700 : FontWeight.w400,
                color: item == value ? colorScheme.primary : null,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
