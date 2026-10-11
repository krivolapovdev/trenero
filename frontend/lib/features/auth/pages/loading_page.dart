import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';

class LoadingPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SizedBox(
        width: double.infinity,
        child: Lottie.asset(AppLottie.loading),
      ),
    ),
  );
}
