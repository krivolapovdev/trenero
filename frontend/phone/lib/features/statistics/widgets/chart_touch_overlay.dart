import 'package:flutter/material.dart';

class ChartTouchOverlay extends StatelessWidget {
  final int itemCount;
  final ValueChanged<int> onIndexChanged;

  const new({super.key, required this.itemCount, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(itemCount, (index) {
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onIndexChanged(index),
            child: const SizedBox.expand(),
          ),
        );
      }),
    );
  }
}
