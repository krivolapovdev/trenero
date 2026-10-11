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

class GroupReportBottomSheet extends ConsumerStatefulWidget {
  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupReportBottomSheet> createState() =>
      _GroupReportBottomSheetState();
}

class _GroupReportBottomSheetState
    extends ConsumerState<GroupReportBottomSheet> {
  static const int _monthDigits = 2;

  late final DateTime _latest = DateTime.now();

  late final TextEditingController _monthController;
  late final TextEditingController _yearController;

  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();

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

  int? get _month {
    final month = int.tryParse(_monthController.text);

    return month != null && month >= 1 && month <= DateTime.december
        ? month
        : null;
  }

  int? get _year {
    final year = int.tryParse(_yearController.text);

    if (year == null) return null;

    return year >= widget.group.createdAt.year && year <= _latest.year
        ? year
        : null;
  }

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

  String? get _monthError {
    final month = _month;

    if (month == null) return _monthController.text.isEmpty ? null : _invalid;

    if (_year == _latest.year && month > _latest.month) return _invalid;

    return null;
  }

  String? get _yearError {
    if (_yearController.text.length < 4) return null;

    return _year == null ? _invalid : null;
  }

  String get _invalid => context.t.invalidDate;

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

            _MonthField(controller: _monthController, errorText: _monthError),
            const SizedBox(height: 16),
            _YearField(controller: _yearController, errorText: _yearError),

            if (reportState != null && reportState.hasError) ...[
              const SizedBox(height: 12),
              _ReportError(period: period!, error: reportState.error),
            ],

            if (report != null) ...[
              const SizedBox(height: 22),
              _ReportPreview(report: report),
            ],

            const SizedBox(height: 22),

            Align(
              alignment: Alignment.centerRight,
              child: _PrintButton(
                isPrinting: _isPrinting,
                enabled: period != null && report != null && !_isPrinting,
                onPressed: () => _printReport(period!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const new({required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_GroupReportBottomSheetState._monthDigits),
    ],
    decoration: InputDecoration(
      labelText: context.t.month,
      hintText: 'MM',
      errorText: errorText,
    ),
  );
}

class _YearField extends StatelessWidget {
  static const int _yearDigits = 4;

  final TextEditingController controller;
  final String? errorText;

  const new({required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(_yearDigits),
    ],
    decoration: InputDecoration(
      labelText: context.t.year,
      hintText: 'YYYY',
      errorText: errorText,
    ),
  );
}

class _ReportPreview extends StatelessWidget {
  static const double _maxHeight = 260;

  final GroupReportResponse report;

  const new({required this.report});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: _maxHeight),
    child: SingleChildScrollView(child: GroupReportTable(report: report)),
  );
}

class _PrintButton extends StatelessWidget {
  final bool isPrinting;
  final bool enabled;
  final VoidCallback onPressed;

  const new({
    required this.isPrinting,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: enabled ? onPressed : null,
    icon: isPrinting
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null,
    label: Text(context.t.print, style: const TextStyle(fontSize: 18)),
  );
}

class _ReportError extends ConsumerWidget {
  final GroupReportPeriod period;
  final Object? error;

  const new({required this.period, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Row(
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
