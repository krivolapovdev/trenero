import 'package:flutter/material.dart';

/// Wraps [child] so it can host a scrollable child of a pull to refresh while
/// still centring its content when there is spare vertical space.
class ScrollableFit extends StatelessWidget {
  final Widget child;

  const new({super.key, required this.child});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: child,
      ),
    ),
  );
}
