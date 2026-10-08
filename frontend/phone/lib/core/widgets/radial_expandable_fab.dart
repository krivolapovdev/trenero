import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Padding for scrollable page content so the floating actions never cover it.
const EdgeInsets kRadialFabContentPadding = EdgeInsets.fromLTRB(
  16,
  16,
  16,
  128,
);

class RadialExpandableFab extends StatefulWidget {
  const new({
    super.key,
    required this.children,
    this.distance = 100.0,
    this.initialOpen = false,
  });

  final List<Widget> children;
  final double distance;
  final bool initialOpen;

  @override
  State<RadialExpandableFab> createState() => _RadialExpandableFabState();
}

class _RadialExpandableFabState extends State<RadialExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen;
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  BoxDecoration _buildShadowDecoration() => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        _buildTapToCloseOverlay(),
        ..._buildActionButtons(),
        _buildPrimaryFab(),
      ],
    ),
  );

  Widget _buildTapToCloseOverlay() {
    if (!_isOpen) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.translucent,
      child: const SizedBox.expand(),
    );
  }

  List<Widget> _buildActionButtons() {
    final list = <Widget>[];
    final count = widget.children.length;
    final step = count > 1 ? math.pi / (count - 1) : 0.0;

    for (var i = 0; i < count; i++) {
      final angle = math.pi - (i * step);

      final dx = widget.distance * math.cos(angle);
      final dy = -widget.distance * math.sin(angle);

      list.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              dx * _expandAnimation.value,
              dy * _expandAnimation.value,
            ),
            child: FadeTransition(
              opacity: _expandAnimation,
              child: ScaleTransition(scale: _expandAnimation, child: child),
            ),
          ),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerUp: (_) {
              if (_isOpen) {
                _toggle();
              }
            },
            child: Container(
              decoration: _buildShadowDecoration(),
              child: widget.children[i],
            ),
          ),
        ),
      );
    }
    return list;
  }

  Widget _buildPrimaryFab() => Container(
    decoration: _buildShadowDecoration(),
    child: FloatingActionButton(
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: _toggle,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _expandAnimation,
      ),
    ),
  );
}
