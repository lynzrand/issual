import 'package:flutter/material.dart';
import 'filerw.dart';

enum TodoStateChangeType {
  flip,
  add,
  view,
  remove,
  wipe,
}

class TodoStateChangeNotification extends Notification {
  TodoStateChangeNotification({this.id, @required this.stateChange, this.data});
  final String id;
  final TodoStateChangeType stateChange;
  final dynamic data;

  String toString() {
    return 'TodoStateChangeNotification(id: $id, stateChange: $stateChange, data: ${data.toString()})';
  }
}

class TodoEditNotification extends Notification {
  TodoEditNotification({this.newTodo = false, this.rawTodo, this.category});
  bool newTodo;
  Map<String, dynamic> rawTodo;
  // Todo todo;
  TodoCategory category;
  @override
  String toString() {
    return 'TodoEditNotification( newTodo: $newTodo, rawTodo: $rawTodo, category: $category )';
  }
}

enum TodoCategoryChangeType {
  add,
  remove,
  rename,
}

class TodoCategoryChangeNotification extends Notification {
  TodoCategoryChangeNotification({@required this.type, this.data});

  final TodoCategoryChangeType type;
  dynamic data;

  String toString() {
    return 'TodoStateChangeNotification( type: $type, data: $data )';
  }
}

enum TodoTagNotificationState { add, remove, view }

class TodoTagNotification {
  TodoTagNotification(this.state, this.data);
  final TodoTagNotificationState state;
  final dynamic data;
}

class CategoryColorSelectorNotification extends Notification {
  CategoryColorSelectorNotification(this.key);
  final String key;
}
