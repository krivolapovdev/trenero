import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A sliver placed at the end of a [CustomScrollView] with a collapsible header.
///
/// It ensures there is always enough scrollable extent ([snapOffset] + [minPadding])
/// for the header to collapse fully into its Short state, even when the content
/// list is short.
class HeaderBottomSpacer extends StatelessWidget {
  final double snapOffset;
  final double minPadding;

  const new({super.key, required this.snapOffset, this.minPadding = 24.0});

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final needed =
          (constraints.viewportMainAxisExtent + snapOffset + minPadding) -
          constraints.precedingScrollExtent;
      final spacerHeight = math.max(minPadding, needed);
      return SliverToBoxAdapter(child: SizedBox(height: spacerHeight));
    },
  );
}
