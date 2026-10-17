import 'package:flutter/material.dart';

class ReportCell extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const new({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: child,
  );
}
