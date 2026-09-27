import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/error_page.dart';
import 'package:phone/features/auth/pages/auth_page.dart';
import 'package:phone/features/auth/pages/loading_page.dart';
import 'package:phone/features/auth/providers/auth_notifier.dart';
import 'package:phone/features/shell/pages/main_shell_screen.dart';

class AuthGate extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider);

    return authNotifier.when(
      loading: () => const LoadingPage(),
      error: (_, _) => const GlobalErrorPage(),
      data: (authStatus) => authStatus == AuthStatus.authenticated
          ? const MainShellScreen()
          : const AuthPage(),
    );
  }
}
