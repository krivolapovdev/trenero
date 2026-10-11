import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks the user to confirm the deletion of a record.
///
/// The sheet shows [title] and [message] above the action that deletes and the
/// action that cancels it. The delete action runs [delete] and stays locked
/// while it runs: the sheet pops with `true` once the record is gone, and keeps
/// itself open, telling the user why, when the deletion failed.
///
/// The caller is the one that pops with `true` from the outside, so this sheet
/// only reports the outcome of [delete].
class DeleteConfirmationSheet extends StatefulWidget {
  /// The headline of the sheet, e.g. `Delete transaction?`.
  final String title;

  /// The consequence of the deletion, e.g. `The transaction will be deleted
  /// permanently. This action cannot be undone.`.
  final String message;

  /// Runs the deletion and returns the failure message, or `null` when the
  /// record was deleted.
  final Future<String?> Function() delete;

  const new({
    super.key,
    required this.title,
    required this.message,
    required this.delete,
  });

  @override
  State<DeleteConfirmationSheet> createState() =>
      _DeleteConfirmationSheetState();
}

class _DeleteConfirmationSheetState extends State<DeleteConfirmationSheet> {
  bool _isLoading = false;

  Future<void> _onDelete() async {
    setState(() {
      _isLoading = true;
    });

    final error = await widget.delete();

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    AppSnackBar.show(context, error, SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            widget.message,
            style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _onDelete,
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
