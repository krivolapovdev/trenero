import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

enum SnackBarType { success, error, warning, help }

class AppSnackBar {
  static void show(BuildContext context, String message, SnackBarType type) {
    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: '${context.t.error}...',
        message: message,
        contentType: switch (type) {
          SnackBarType.success => ContentType.success,
          SnackBarType.warning => ContentType.warning,
          SnackBarType.help => ContentType.help,
          SnackBarType.error => ContentType.failure,
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
