import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/models/group_report_response.dart';

class ReportPreview extends StatelessWidget {
  static const double _maxHeight = 260;

  final GroupReportResponse report;

  const new({super.key, required this.report});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: _maxHeight),
    child: SingleChildScrollView(child: GroupReportTable(report: report)),
  );
}
