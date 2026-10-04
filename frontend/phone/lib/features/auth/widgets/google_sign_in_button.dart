import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone/core/constants/app_assets.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/auth/providers/auth_notifier.dart';
import 'package:phone/i18n/strings.g.dart';

class GoogleSignInButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthStatus>>(authNotifierProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        AppSnackBar.show(context, 'Error: ${next.error}', SnackBarType.error);
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: authState.isLoading
            ? null
            : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
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
              context.t.auth.signInWithGoogle,
              style: const TextStyle(
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
