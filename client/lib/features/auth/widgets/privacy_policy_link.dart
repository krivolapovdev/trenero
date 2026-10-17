import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_constants.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyLink extends StatelessWidget {
  static const Color _textColor = Color(0xFF6E6A78);

  const new({super.key});

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
