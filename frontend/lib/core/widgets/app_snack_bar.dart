import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum SnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
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
      autoCloseDuration: Duration(seconds: type == SnackBarType.error ? 12 : 4),
      closeOnClick: true,
      pauseOnHover: true,
    );
  }
}
