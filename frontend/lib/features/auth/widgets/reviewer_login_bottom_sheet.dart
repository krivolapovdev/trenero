import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/outlined_input_field.dart';
import 'package:phone/features/auth/controllers/reviewer_auth_controller.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks for the reviewer key and logs in with it.
///
/// Pops with `true` when the key was accepted.
class ReviewerLoginBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ReviewerLoginBottomSheet> createState() =>
      _ReviewerLoginBottomSheetState();
}

class _ReviewerLoginBottomSheetState
    extends ConsumerState<ReviewerLoginBottomSheet> {
  final TextEditingController _reviewerKeyController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _reviewerKeyController.addListener(_onKeyChanged);
  }

  void _onKeyChanged() => setState(() {});

  @override
  void dispose() {
    _reviewerKeyController.dispose();
    super.dispose();
  }

  bool get _isKeyEmpty => _reviewerKeyController.text.trim().isEmpty;

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(reviewerAuthControllerProvider.notifier)
        .login(_reviewerKeyController.text);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    final error = ref.read(reviewerAuthControllerProvider).error;
    if (error != null) {
      AppSnackBar.show(context, '$error', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 0,
          bottom: 16 + keyboardInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedTextField(
              label: context.t.auth.reviewerKey,
              controller: _reviewerKeyController,
              leadingIcon: const Icon(FluentIcons.key_24_regular),
              enabled: !_isLoading,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: _isLoading || _isKeyEmpty ? null : _onLogin,
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black12,
                  disabledForegroundColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.t.auth.login,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
