import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone/core/constants/app_assets.dart';
import 'package:phone/features/auth/services/google_auth_service.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:phone/share/widgets/error_snack_bar.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: () async {
          try {
            final GoogleAuthService googleAuthService = GoogleAuthService();
            final String? token = await googleAuthService.getGoogleIdToken();
            print('Google ID Token: $token');
          } catch (e) {
            if (!context.mounted) return;
            ErrorSnackBar.show(context, "Error: $e");
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppAssets.googleLogo, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              t.auth.signInWithGoogle,
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
}
