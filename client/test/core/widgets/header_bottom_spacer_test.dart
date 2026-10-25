import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/header_bottom_spacer.dart';

void main() {
  const snapOffset = 136.0;
  const minPadding = 24.0;

  testWidgets(
    'guarantees maxScrollExtent >= snapOffset + minPadding even when preceding content is short',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final height in [200.0, 400.0, 600.0, 750.0, 850.0, 1200.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: height)),
                  const HeaderBottomSpacer(
                    snapOffset: snapOffset,
                    minPadding: minPadding,
                  ),
                ],
              ),
            ),
          ),
        );

        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );

        expect(
          scrollable.position.maxScrollExtent,
          greaterThanOrEqualTo(snapOffset + minPadding),
        );
      }
    },
  );
}
