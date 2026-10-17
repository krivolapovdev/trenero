import 'package:flutter/material.dart';
import 'package:phone/core/widgets/error_details.dart';
import 'package:phone/core/widgets/error_notice.dart';

class GlobalErrorPage extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRepeat;

  const new({super.key, this.error, this.onRepeat});

  @override
  Widget build(BuildContext context) {
    final error = this.error;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: ErrorNotice(onRepeat: onRepeat)),
            if (error != null) ErrorDetails(error: error),
          ],
        ),
      ),
    );
  }
}
