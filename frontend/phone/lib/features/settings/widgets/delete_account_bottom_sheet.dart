import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/settings/controllers/delete_account_controller.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks for confirmation before deleting the account of the current user.
///
/// The delete button stays locked for [countdownSeconds] so the account is not
/// removed by a single accidental tap. The remaining seconds are shown right
/// below the button.
class DeleteAccountBottomSheet extends ConsumerStatefulWidget {
  static const int countdownSeconds = 10;

  const new({super.key});

  @override
  ConsumerState<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState
    extends ConsumerState<DeleteAccountBottomSheet> {
  Timer? _countdownTimer;
  int _secondsRemaining = DeleteAccountBottomSheet.countdownSeconds;
  bool _isLoading = false;

  bool get _canDelete => _secondsRemaining == 0 && !_isLoading;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        return;
      }

      setState(() => _secondsRemaining -= 1);
    });
  }

  Future<void> _onDelete() async {
    setState(() => _isLoading = true);

    final success = await ref
        .read(deleteAccountControllerProvider.notifier)
        .deleteAccount();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _isLoading = false);

    final error = ref.read(deleteAccountControllerProvider).error;
    if (error != null) {
      AppSnackBar.show(context, '$error', SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t.settings.deleteAccount,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            context.t.settings.deleteAccountMessage,
            style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _canDelete
                    ? Colors.red.shade50
                    : Colors.grey.shade200,
                foregroundColor: Colors.red,
                disabledForegroundColor: Colors.black38,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _canDelete ? _onDelete : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      context.t.delete,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),

          if (_secondsRemaining > 0) ...[
            const SizedBox(height: 8),

            Text(
              context.t.settings.deleteAccountCountdown(
                seconds: _secondsRemaining,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.t.cancel,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
