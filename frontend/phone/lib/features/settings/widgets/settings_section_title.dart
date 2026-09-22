import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const new({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 14),
      ),
    );
  }
}
