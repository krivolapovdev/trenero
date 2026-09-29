import 'package:flutter/material.dart';

abstract class AppBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required Widget child,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => child,
  );
}
