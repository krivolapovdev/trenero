import 'package:flutter/material.dart';

class MetricsMessage extends StatelessWidget {
  static const double _height = 200;

  final String message;

  const new({super.key, required this.message});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: Center(child: Text(message)),
  );
}
