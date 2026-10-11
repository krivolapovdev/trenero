import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks for confirmation before deleting the lesson with [lessonId].
///
/// Pops with `true` when the lesson was deleted.
class DeleteLessonBottomSheet extends ConsumerStatefulWidget {
  final String lessonId;
  final String groupId;

  const new({super.key, required this.lessonId, required this.groupId});

  @override
  ConsumerState<DeleteLessonBottomSheet> createState() =>
      _DeleteLessonBottomSheetState();
}

class _DeleteLessonBottomSheetState
    extends ConsumerState<DeleteLessonBottomSheet> {
  bool _isLoading = false;

  Future<void> _onDelete() async {
    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(lessonMutationControllerProvider.notifier)
        .deleteLesson(lessonId: widget.lessonId, groupId: widget.groupId);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    final error = ref.read(lessonMutationControllerProvider).error;
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
            context.t.lessons.deleteLesson,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            context.t.lessons.deleteLessonMessage,
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
