import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/services/pdf_printer.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/models/group_report_period.dart';
import 'package:phone/features/groups/services/group_report_pdf_service.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Types the month of a group report and shows its PDF in the print dialog.
///
/// The month and the year are typed into two fields, the way the other sheets
/// take their dates instead of opening a picker. Only a period up to the
/// current month can be printed: a month that has not started yet has no
/// report, so the fields refuse it.
class GroupReportBottomSheet extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupReportBottomSheet> createState() =>
      _GroupReportBottomSheetState();
}

class _GroupReportBottomSheetState
    extends ConsumerState<GroupReportBottomSheet> {
  /// Amount of digits of a complete year.
  static const int _yearDigits = 4;

  /// The latest month that can be reported on.
  late final DateTime _latest = DateTime.now();

  late final TextEditingController _monthController;
  late final TextEditingController _yearController;

  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();

    // The sheet opens on the current month, the latest one it can print.
    _monthController = TextEditingController(text: '${_latest.month}');
    _yearController = TextEditingController(text: '${_latest.year}');

    _monthController.addListener(_onFieldChanged);
    _yearController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  /// The month typed into the month field, `null` while it is not a month.
  int? get _month {
    final month = int.tryParse(_monthController.text);

    return month != null && month >= 1 && month <= DateTime.december
        ? month
        : null;
  }

  /// The year typed into the year field, `null` while the group cannot have a
  /// report for it.
  int? get _year {
    final year = int.tryParse(_yearController.text);

    if (year == null) return null;

    return year >= widget.group.createdAt.year && year <= _latest.year
        ? year
        : null;
  }

  /// The period the sheet prints, `null` while the typed period is incomplete,
  /// impossible or lies in the future.
  GroupReportPeriod? get _period {
    final month = _month;
    final year = _year;

    if (month == null || year == null) return null;
    if (year == _latest.year && month > _latest.month) return null;

    return GroupReportPeriod(
      groupId: widget.group.id,
      year: year,
      month: month,
    );
  }

  /// The message under the month field, `null` while the typed month is one a
  /// report can be built for.
  String? get _monthError {
    final month = _month;

    if (month == null) return _monthController.text.isEmpty ? null : _invalid;

    // A month of the current year that has not started yet.
    if (_year == _latest.year && month > _latest.month) return _invalid;

    return null;
  }

  /// The message under the year field, `null` while the year can still be
  /// completed and while the typed year is one the group has a history for.
  String? get _yearError {
    // A year is typed digit by digit, so only a complete one is judged.
    if (_yearController.text.length < _yearDigits) return null;

    return _year == null ? _invalid : null;
  }

  String get _invalid => context.t.invalidDate;

  /// Turns the report of the typed month into a PDF and shows it in the print
  /// dialog of the platform.
  Future<void> _printReport(GroupReportPeriod period) async {
    final report = ref.read(groupReportProvider(period)).value;

    if (report == null || _isPrinting) return;

    final t = context.t;
    final locale = ref.read(languageProvider).value?.languageCode;

    setState(() => _isPrinting = true);

    try {
      final bytes = await ref
          .read(groupReportPdfServiceProvider)
          .build(report, t: t, locale: locale);

      if (!mounted) return;

      await ref
          .read(pdfPrinterProvider)
          .print(
            bytes: bytes,
            name: GroupReportPdfService.documentName(report),
            format: GroupReportPdfService.pageFormat,
          );
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        '${context.t.error}: $error',
        SnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = _period;

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    final reportState = period == null
        ? null
        : ref.watch(groupReportProvider(period));
    final report = reportState?.value;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 0, 22, 22 + keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.t.groups.report,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),

            const SizedBox(height: 16),

            _buildMonthField(),
            const SizedBox(height: 16),
            _buildYearField(),

            if (reportState != null && reportState.hasError) ...[
              const SizedBox(height: 12),
              _buildReportError(period!, reportState.error),
            ],

            if (report != null) ...[
              const SizedBox(height: 22),
              _buildReportPreview(report),
            ],

            const SizedBox(height: 22),

            Align(
              alignment: Alignment.centerRight,
              child: _buildPrintButton(period, reportState),
            ),
          ],
        ),
      ),
    );
  }

  /// The report of the typed month, previewing the document the print action
  /// hands over.
  Widget _buildReportPreview(GroupReportResponse report) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 260),
    child: SingleChildScrollView(child: GroupReportTable(report: report)),
  );

  /// The field the month is typed into, e.g. `12`.
  Widget _buildMonthField() => TextField(
    controller: _monthController,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(2),
    ],
    decoration: InputDecoration(
      labelText: context.t.month,
      hintText: 'MM',
      errorText: _monthError,
    ),
  );

  /// The field the year is typed into, e.g. `2026`.
  Widget _buildYearField() => TextField(
    controller: _yearController,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_yearDigits),
    ],
    decoration: InputDecoration(
      labelText: context.t.year,
      hintText: 'YYYY',
      errorText: _yearError,
    ),
  );

  /// Print action of the sheet: disabled until the typed month was loaded.
  Widget _buildPrintButton(
    GroupReportPeriod? period,
    AsyncValue<GroupReportResponse>? reportState,
  ) => TextButton.icon(
    onPressed: period == null || reportState?.value == null || _isPrinting
        ? null
        : () => _printReport(period),
    icon: _isPrinting
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(context.t.print, style: const TextStyle(fontSize: 18)),
  );

  /// The failure of the report of the typed month, with a way to read it
  /// again.
  Widget _buildReportError(GroupReportPeriod period, Object? error) => Row(
    children: [
      Expanded(
        child: Text(
          '${context.t.error}: $error',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),

      TextButton(
        onPressed: () =>
            ref.read(groupReportProvider(period).notifier).refresh(),
        child: Text(context.t.repeat),
      ),
    ],
  );
}
