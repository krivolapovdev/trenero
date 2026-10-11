import 'package:flutter/material.dart';
import 'package:phone/features/auth/widgets/google_sign_in_button.dart';
import 'package:phone/features/auth/widgets/privacy_policy_link.dart';
import 'package:phone/features/auth/widgets/reviewer_login_trigger.dart';

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

            ReviewerLoginTrigger(),

            GoogleSignInButton(),

            Spacer(flex: 4),

            Divider(color: Color(0xFFD4CDDF), thickness: 1),

            SizedBox(height: 12),

            PrivacyPolicyLink(),

            SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
