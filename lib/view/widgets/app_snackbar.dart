import 'package:flutter/material.dart';

void showMessengerSnackBar(
  ScaffoldMessengerState messenger,
  String message, {
  Color? color,
  SnackBarAction? action,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      action: action,
    ));
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? color,
  SnackBarAction? action,
}) {
  showMessengerSnackBar(
    ScaffoldMessenger.of(context),
    message,
    color: color,
    action: action,
  );
}
