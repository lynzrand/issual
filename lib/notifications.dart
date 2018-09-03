import 'package:flutter/material.dart';

class TodoStateChangeNotification extends Notification {
  TodoStateChangeNotification({this.id, @required this.stateChange, this.data});
  final String id;
  final String stateChange;
  final dynamic data;

  String toString() {
    return 'TodoStateChangeNotification(id: $id, stateChange: $stateChange, data: ${data.toString()})';
  }
}

class TodoEditNotification extends Notification {
  TodoEditNotification({this.newTodo = false, this.rawTodo});
  bool newTodo;
  Map<String, dynamic> rawTodo;
}
