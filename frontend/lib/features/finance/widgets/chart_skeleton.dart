import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/chart_skeleton_colors.dart';
import 'package:phone/features/finance/widgets/chart_skeleton_painter.dart';
import 'package:phone/features/finance/widgets/month_label_bone.dart';
import 'package:shimmer/shimmer.dart';

class ChartSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Container(
    height: 380,
    padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    child: Shimmer.fromColors(
      baseColor: chartSkeletonBoneColor,
      highlightColor: chartSkeletonBoneHighlightColor,
      child: Column(
        children: [
          const Expanded(
            child: CustomPaint(
              painter: ChartSkeletonPainter(),
              child: SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              6,
              (index) => const Expanded(child: Center(child: MonthLabelBone())),
            ),
          ),
        ],
      ),
    ),
  );
}
