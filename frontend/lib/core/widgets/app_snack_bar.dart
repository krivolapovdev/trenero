import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

enum SnackBarType { success, error, warning, help }

abstract final class AppSnackBar {
  static const Duration _overlayDuration = Duration(seconds: 4);

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

  static bool _isCoveredByModal(BuildContext context) {
    final route = ModalRoute.of(context);

    return route is PopupRoute && !route.isFirst;
  }

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

  static void _removeOverlay(OverlayEntry entry) {
    if (_overlayEntry != entry) return;

    _overlayTimer?.cancel();
    _overlayTimer = null;
    _overlayEntry = null;
    entry.remove();
  }

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
