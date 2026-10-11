import 'package:flutter/material.dart';

class SheetTitle extends StatelessWidget {
  final String title;

  const new({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 20, color: Colors.black),
    textAlign: TextAlign.center,
  );
}
