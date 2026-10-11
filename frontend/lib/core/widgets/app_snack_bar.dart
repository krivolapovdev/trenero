import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

enum SnackBarType { success, error, warning, help }

/// Shows transient notifications to the user.
///
/// A regular snack bar is owned by the [Scaffold] of the page it was shown
/// from, so a modal route opened above that page (a bottom sheet, a dialog,
/// ...) covers it. Whenever such a modal route is on top, the notification is
/// rendered in the root [Overlay] instead, which keeps it visible above the
/// modal.
class AppSnackBar {
  /// How long the notification stays on top of a modal before it hides itself.
  ///
  /// Matches the default duration of a [SnackBar].
  static const Duration _overlayDuration = Duration(seconds: 4);

  /// The notification currently shown on top of a modal, if any.
  static OverlayEntry? _overlayEntry;
  static Timer? _overlayTimer;

  static void show(BuildContext context, String message, SnackBarType type) {
    final content = AwesomeSnackbarContent(
      title: '${context.t.error}...',
      message: message,
      contentType: switch (type) {
        SnackBarType.success => ContentType.success,
        SnackBarType.warning => ContentType.warning,
        SnackBarType.help => ContentType.help,
        SnackBarType.error => ContentType.failure,
      },
    );

    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

    if (_isCoveredByModal(context)) {
      _showOverModal(context, content);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(_snackBar(content));
  }

  /// Whether a modal route (bottom sheet, dialog, ...) covers the page the
  /// notification is shown from.
  static bool _isCoveredByModal(BuildContext context) {
    final route = ModalRoute.of(context);

    return route is PopupRoute && !route.isFirst;
  }

  /// Renders [content] at the top of the root overlay, above every route.
  static void _showOverModal(BuildContext context, Widget content) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);

    if (overlay == null) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(content));
      return;
    }

    _hideOverlay();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _OverlaySnackBar(
        content: content,
        onDismissed: () => _removeOverlay(entry),
      ),
    );

    _overlayEntry = entry;
    overlay.insert(entry);

    _overlayTimer = Timer(_overlayDuration, () => _removeOverlay(entry));
  }

  /// Removes [entry] when it is still the notification on screen.
  static void _removeOverlay(OverlayEntry entry) {
    if (_overlayEntry != entry) return;

    _overlayTimer?.cancel();
    _overlayTimer = null;
    _overlayEntry = null;
    entry.remove();
  }

  /// Removes the notification on screen, if any.
  static void _hideOverlay() {
    _overlayTimer?.cancel();
    _overlayTimer = null;

    final entry = _overlayEntry;
    _overlayEntry = null;
    entry?.remove();
  }

  static SnackBar _snackBar(Widget content) => SnackBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    content: content,
  );
}

/// Paints a snack bar like notification at the top of the overlay.
///
/// The content sits in a local [ScaffoldMessenger] so that the close button of
/// [AwesomeSnackbarContent] does not touch the page messengers below the modal
/// and tapping the notification closes it instead.
class _OverlaySnackBar extends StatefulWidget {
  final Widget content;
  final VoidCallback onDismissed;

  const new({required this.content, required this.onDismissed});

  @override
  State<_OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<_OverlaySnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Plays the exit animation and removes the notification afterwards.
  Future<void> _dismiss() async {
    await _controller.reverse();

    if (!mounted) return;

    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _controller,
            child: ScaffoldMessenger(
              child: Listener(
                onPointerDown: (_) => unawaited(_dismiss()),
                child: Material(
                  color: Colors.transparent,
                  child: widget.content,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
