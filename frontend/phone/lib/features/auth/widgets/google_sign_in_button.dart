import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone/core/constants/app_assets.dart';
import 'package:phone/core/providers/auth_provider.dart';
import 'package:phone/features/auth/pages/loading_page.dart';
import 'package:phone/features/auth/services/google_auth_service.dart';
import 'package:phone/features/auth/services/oauth2_service.dart';
import 'package:phone/features/shell/pages/main_shell_screen.dart';
import 'package:phone/generated/models/login_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:phone/core/widgets/error_snack_bar.dart';

class GoogleSignInButton extends ConsumerWidget {
  const new({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final String? token = await googleAuthService.getGoogleIdToken();

      if (token == null || !context.mounted) {
        return;
      }

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoadingPage()));

      final LoginResponse response = await oAuth2Service.googleLogin(token);
      await ref.read(authProvider.notifier).setAuth(response);

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainShellScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ErrorSnackBar.show(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
    width: double.infinity,
    height: 56,
    child: TextButton(
      onPressed: () => _handleGoogleSignIn(context, ref),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppAssets.googleLogo, height: 24, width: 24),
          const SizedBox(width: 12),
          Text(
            context.t.auth.signInWithGoogle,
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
