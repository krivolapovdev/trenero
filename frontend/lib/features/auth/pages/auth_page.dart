import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/auth/widgets/google_sign_in_button.dart';
import 'package:phone/features/auth/widgets/reviewer_login_bottom_sheet.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Spacer(flex: 3),

            _ReviewerLoginTrigger(),

            GoogleSignInButton(),

            Spacer(flex: 4),

            Divider(color: Color(0xFFD4CDDF), thickness: 1),

            SizedBox(height: 12),

            _PrivacyPolicyLink(),

            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

class _ReviewerLoginTrigger extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onLongPress: () => AppBottomSheet.show(
      context: context,
      child: const ReviewerLoginBottomSheet(),
    ),
    child: Lottie.asset(AppLottie.profilePasswordUnlock),
  );
}

class _PrivacyPolicyLink extends StatelessWidget {
  static const Color _textColor = Color(0xFF6E6A78);

  const new();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(
      Uri.parse(AppConstants.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    ),
    child: Text(
      context.t.auth.agreePrivacyPolicy,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _textColor, fontSize: 13, height: 1.35),
    ),
  );
}
