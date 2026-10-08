import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/services/pdf_printer.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/models/group_report_period.dart';
import 'package:phone/features/groups/services/group_report_pdf_service.dart';
import 'package:phone/features/groups/widgets/group_report_period_picker.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Monthly attendance report of a group: a table with one column per day of the
/// selected month, the payment state of every student and the summed result.
class GroupReportPage extends ConsumerStatefulWidget {
  /// Rows shown while the report of the selected month is loading.
  static const int placeholderStudentCount = 5;

  /// Days that the loading placeholder marks as lesson days.
  static const Set<int> placeholderLessonDays = {2, 4, 7, 9, 11, 14, 16};

  final GroupSummaryResponse group;

  const new({super.key, required this.group});

  @override
  ConsumerState<GroupReportPage> createState() => _GroupReportPageState();
}

class _GroupReportPageState extends ConsumerState<GroupReportPage> {
  late int _year = DateTime.now().year;
  late int _month = DateTime.now().month;
  bool _isPrinting = false;

  GroupReportPeriod get _period =>
      GroupReportPeriod(groupId: widget.group.id, year: _year, month: _month);

  /// Years of the picker: from the creation year of the group to the next year.
  List<int> get _yearOptions {
    final lastYear = DateTime.now().year + 1;

    return [
      for (var year = widget.group.createdAt.year; year <= lastYear; year++)
        year,
    ];
  }

  /// Turns the report of the selected month into a PDF and hands it over to the
  /// print dialog of the platform.
  Future<void> _printReport() async {
    final report = ref.read(groupReportProvider(_period)).value;

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
          );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
      print(error);
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  /// Print action of the app bar: disabled until the month has been loaded.
  Widget _buildPrintAction(
    BuildContext context,
    AsyncValue<GroupReportResponse> reportState,
  ) {
    if (_isPrinting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return IconButton(
      tooltip: context.t.print,
      icon: const Icon(Icons.print),
      onPressed: reportState.value == null ? null : _printReport,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(groupReportProvider(_period));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.groups.report),
        actions: [
          _buildPrintAction(context, reportState),
          const SizedBox(width: 8),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GroupReportPeriodPicker(
                year: _year,
                month: _month,
                years: _yearOptions,
                onYearChanged: (year) => setState(() => _year = year),
                onMonthChanged: (month) => setState(() => _month = month),
              ),
            ),
          ),
          Expanded(child: _buildBody(context, reportState)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<GroupReportResponse> reportState,
  ) {
    final report = reportState.value;

    if (report == null && reportState.hasError) {
      return _buildError(context, reportState.error);
    }

    return Skeletonizer(
      enabled: reportState.isLoading,
      ignorePointers: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: GroupReportTable(report: report ?? _buildPlaceholderReport()),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object? error) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${context.t.error}: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () =>
                    ref.read(groupReportProvider(_period).notifier).refresh(),
                child: Text(context.t.repeat),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  /// Fills the table with the shape of the selected month while it loads.
  GroupReportResponse _buildPlaceholderReport() {
    final dayCount = daysInMonth(_year, _month);
    final lessonDays = GroupReportPage.placeholderLessonDays
        .where((day) => day <= dayCount)
        .toList();

    final students = List.generate(GroupReportPage.placeholderStudentCount, (
      index,
    ) {
      final presentDays = lessonDays
          .where((day) => (index + day).isEven)
          .toList();

      return GroupReportStudentResponse(
        studentId: 'placeholder-$index',
        fullName: 'Student Name Placeholder',
        paid: index.isEven,
        presentDays: presentDays,
        presentCount: presentDays.length,
        lessonCount: lessonDays.length,
      );
    });

    return GroupReportResponse(
      groupId: widget.group.id,
      groupName: widget.group.name,
      year: _year,
      month: _month,
      dayCount: dayCount,
      lessonDays: lessonDays,
      students: students,
      totalPresent: students.fold(0, (sum, s) => sum + s.presentCount),
      totalLessons: students.fold(0, (sum, s) => sum + s.lessonCount),
    );
  }
}
