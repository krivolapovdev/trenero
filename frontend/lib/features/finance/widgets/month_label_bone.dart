import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/chart_skeleton_colors.dart';

class MonthLabelBone extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 12,
    decoration: const BoxDecoration(
      color: chartSkeletonBoneColor,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
  );
}
