import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/features/auth/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(flex: 3),

            Lottie.asset(AppLottie.profilePasswordUnlock),
            GoogleSignInButton(),

            const Spacer(flex: 4),

            const Divider(color: Color(0xFFD4CDDF), thickness: 1),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => launchUrl(
                Uri.parse(AppConstants.privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                context.t.auth.agreePrivacyPolicy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6E6A78),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
