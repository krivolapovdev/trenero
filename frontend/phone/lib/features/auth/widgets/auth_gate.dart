import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/error_page.dart';
import 'package:phone/features/auth/pages/loading_page.dart';
import 'package:phone/core/providers/auth_provider.dart';
import 'package:phone/features/shell/pages/main_shell_screen.dart';

class AuthGate extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInit = ref.watch(authInitializerProvider);

    return authInit.when(
      loading: () => const LoadingPage(),
      error: (_, _) => const GlobalErrorPage(),
      data: (isAuthenticated) =>
          // isAuthenticated ? const MainShellScreen() : const AuthPage(),
          const MainShellScreen(),
    );
  }
}
