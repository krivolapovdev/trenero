import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/auth/widgets/reviewer_login_bottom_sheet.dart';

class ReviewerLoginTrigger extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPress: () => AppBottomSheet.show(
      context: context,
      child: const ReviewerLoginBottomSheet(),
    ),
    child: Lottie.asset(AppLottie.profilePasswordUnlock),
  );
}
