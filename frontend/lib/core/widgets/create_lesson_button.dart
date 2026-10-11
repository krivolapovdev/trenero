import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

/// The action that opens the page creating a lesson.
///
/// The label and the look of the action are shared by every place a lesson is
/// created from: the calendar of a group carries the button under its grid,
/// while the individual lesson is created from the action of the app bar of the
/// page. Sharing the button keeps both kinds of lesson reading the same.
class CreateLessonButton extends StatelessWidget {
  /// Opens the page that creates the lesson. A button without an action is
  /// drawn disabled, the way every button of the framework is.
  final VoidCallback? onPressed;

  const new({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: Text(context.t.create, style: const TextStyle(fontSize: 16)),
  );
}
