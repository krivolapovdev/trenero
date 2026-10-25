import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/header_bottom_spacer.dart';
import 'package:phone/core/widgets/header_snap_scroll_physics.dart';

void main() {
  const snapOffset = 136.0;

  Widget buildTestableWidget({double contentHeight = 1000.0}) => MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        physics: const HeaderSnapScrollPhysics(
          snapOffset: snapOffset,
          parent: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: contentHeight)),
          const HeaderBottomSpacer(snapOffset: snapOffset),
        ],
      ),
    ),
  );

  testWidgets('snaps to 0 (Full) when drag is less than half of snapOffset', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget());
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -30));
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, equals(0.0));
  });

  testWidgets(
    'snaps to snapOffset (Short) when drag exceeds half of snapOffset',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, equals(snapOffset));
    },
  );

  testWidgets(
    'snaps back to snapOffset (Short) when dragging down slightly from Short',
    (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

      // First collapse to Short
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, equals(snapOffset));

      // Drag slightly downwards (30px) -> position stays > midpoint (68)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 30));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, equals(snapOffset));
    },
  );

  testWidgets('snaps to 0 (Full) when dragging down past midpoint from Short', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget());
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    // First collapse to Short
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, equals(snapOffset));

    // Drag downwards past midpoint (90px)
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 90));
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, equals(0.0));
  });

  testWidgets('allows normal continuous scrolling beyond snapOffset', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(contentHeight: 2000));
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(300.0));
  });
}
