import 'package:flutter/material.dart';

class ChartBottomTitle extends StatelessWidget {
  final String text;
  final bool isSelected;

  const new({super.key, required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
