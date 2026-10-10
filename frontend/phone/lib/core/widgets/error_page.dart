import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/i18n/strings.g.dart';

class GlobalErrorPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Lottie.asset(AppLottie.error),
          ),
          Text(
            context.t.somethingWentWrong,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    ),
  );
}
