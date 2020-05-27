import 'package:flutter/material.dart';

ScaffoldState showMessageBar(BuildContext context, String message) {
  final scaffold = Scaffold.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
          label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
    ),
  );

  return scaffold;
}