import 'package:flutter/cupertino.dart';

@immutable
class Messages {
  final String title;
  final String body;

  const Messages({
    @required this.title,
    @required this.body,
  });
}