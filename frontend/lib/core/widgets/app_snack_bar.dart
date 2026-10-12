import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum SnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static const Duration _autoCloseDuration = Duration(seconds: 4);

  static void show(
    BuildContext context,
    String title,
    String message,
    SnackBarType type,
  ) {
    toastification.dismissAll(delayForAnimation: false);

    toastification.show(
      context: context,
      alignment: Alignment.bottomCenter,
      type: switch (type) {
        SnackBarType.success => ToastificationType.success,
        SnackBarType.warning => ToastificationType.warning,
        SnackBarType.info => ToastificationType.info,
        SnackBarType.error => ToastificationType.error,
      },
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: type == SnackBarType.error ? null : _autoCloseDuration,
      closeOnClick: true,
      pauseOnHover: true,
    );
  }
}
