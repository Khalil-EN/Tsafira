import 'package:flutter/material.dart';
import 'dart:async';

/// Opens a dialog one frame later than [showDialog] would.
///
/// Needed whenever a dialog is triggered from inside a widget whose own
/// tap (an InkWell splash) or a PopupMenuButton's closing route is still
/// inserting/removing an OverlayEntry in the same frame — calling
/// showDialog synchronously in that situation can throw a
/// "Duplicate GlobalKeys" error because both routes race for the same
/// Overlay. Deferring to the next frame lets the triggering route finish
/// first.
Future<T?> showSafeDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final completer = Completer<T?>();

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) {
      completer.complete(null);
      return;
    }

    final result = await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );

    completer.complete(result);
  });

  return completer.future;
}

/// Convenience wrapper for the extremely common
/// "Delete/Ban/Remove X?" confirm-cancel pattern.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = true,
  bool deferred = true,
}) async {
  Future<bool?> open() => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  final result = deferred
      ? await showSafeDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  )
      : await open();

  return result == true;
}