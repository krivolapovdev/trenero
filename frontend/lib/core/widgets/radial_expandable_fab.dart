import 'dart:math' as math;

import 'package:flutter/material.dart';

const EdgeInsets kRadialFabContentPadding = EdgeInsets.fromLTRB(
  16,
  16,
  16,
  128,
);

final BoxDecoration _shadowDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      spreadRadius: 1,
    ),
  ],
);

class RadialExpandableFab extends StatefulWidget {
  final List<Widget> children;
  final double distance;
  final bool initialOpen;

  const new({
    super.key,
    required this.children,
    this.distance = 100.0,
    this.initialOpen = false,
  });

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

  void _collapseIfOpen() {
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    final step = count > 1 ? math.pi / (count - 1) : 0.0;

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          _TapToCloseOverlay(isOpen: _isOpen, onTap: _toggle),
          for (var index = 0; index < count; index++)
            _RadialAction(
              animation: _expandAnimation,
              angle: math.pi - (index * step),
              distance: widget.distance,
              onCollapse: _collapseIfOpen,
              child: widget.children[index],
            ),
          _PrimaryFab(animation: _expandAnimation, onPressed: _toggle),
        ],
      ),
    );
  }
}

class _TapToCloseOverlay extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const new({required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: const SizedBox.expand(),
    );
  }
}

class _RadialAction extends StatelessWidget {
  final Animation<double> animation;
  final double angle;
  final double distance;
  final VoidCallback onCollapse;
  final Widget child;

  const new({
    required this.animation,
    required this.angle,
    required this.distance,
    required this.onCollapse,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dx = distance * math.cos(angle);
    final dy = -distance * math.sin(angle);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(dx * animation.value, dy * animation.value),
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => onCollapse(),
        child: Container(decoration: _shadowDecoration, child: child),
      ),
    );
  }
}

class _PrimaryFab extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const new({required this.animation, required this.onPressed});

  @override
  Widget build(BuildContext context) => Container(
    decoration: _shadowDecoration,
    child: FloatingActionButton(
      elevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: onPressed,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: animation,
      ),
    ),
  );
}
