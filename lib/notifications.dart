import 'package:flutter/material.dart';

class TodoStateChangeNotification extends Notification {
  TodoStateChangeNotification({this.id, @required this.stateChange, this.data});
  final String id;
  final String stateChange;
  final dynamic data;
}
