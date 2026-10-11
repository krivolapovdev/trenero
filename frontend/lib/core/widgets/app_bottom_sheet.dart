import 'package:flutter/material.dart';

abstract class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) => showModalBottomSheet<T>(
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
