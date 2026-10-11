import 'package:flutter/material.dart';

class DaySectionTitle extends StatelessWidget {
  final String title;

  const new({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  );
}
