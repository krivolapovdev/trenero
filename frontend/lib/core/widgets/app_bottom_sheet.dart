import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';

abstract final class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) => showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.topRounded),
    builder: (context) => child,
  );
}
