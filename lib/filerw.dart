import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';

enum TodoState { Open, Closed, Active, Pending, Finished }

class Todo {
  /// Unique identifier of the todo
  /// Using a 26-digit ULID string.
  String id;

  /// Title of the Todo
  String title;

  /// State of the todo. Avaliable: Open, Closed, Active, Pending, Finished.
  TodoState state;

  /// Description of the todo. (I wish it is) Markdown compatible.
  String desc;

  /// Deadline of the todo.
  DateTime ddl;

  Todo({final Map<String, dynamic> rawTodo, bool isNewTodo = false}) {
    if (isNewTodo && (rawTodo == null || rawTodo['id'] == null))
      this.id = new Ulid().toCanonical();
    else
      this.id = rawTodo['id'];
  }
}

class Filerw {
  Filerw() {
    debugPrint('[FileRW] Use Filerw.init() to initialize database');
  }

  String _path;
  Database _db;

  void init() async {
    this._path = await getDatabasesPath() + "todo.db";
    this._db = await openDatabase(this._path, onCreate: (Database db, int v) {
      db.execute('''
        CREATE TABLE Todolist (
          id TEXT  primary key  collate nocase,
          title TEXT,
          state INTEGER,
          desc TEXT,
          ddl INTEGER
        );
        CREATE TABLE Configs (
          usePending INTEGER,
          useFinished INTEGER
        );
        ''');
    });
    // this._db =
  }

  /// Get Todos within 3 monts OR is active
  Future<Map<String, Todo>> getRecentTodos() async {
    String startID = new Ulid(
            millis: DateTime.now()
                .subtract(new Duration(days: 92))
                .microsecondsSinceEpoch)
        .toCanonical()
        .replaceRange(10, 25, '0' * 16);
    List<dynamic> rawTodos = await this._db.query('Todolist',
        where: 'id > $startID OR state == "Active" OR state == "Pending"');
    Map<String, Todo> todos;
    for (var rawTodo in rawTodos) {
      Todo todo = new Todo(rawTodo: rawTodo);
      todos[todo.id] = todo;
    }
    return todos;
  }

  Future<int> countTodos(
      {TodoState state,
      String category,
      DateTime beforeTime,
      DateTime afterTime}) async {
    int num = 0;
    // Count todos
    String query = 'SELECT COUNT(*) FROM Todolist WHERE 0 == 0';

    // With specific state
    if (state != null) query += 'AND state == "$state"';
    // And specific category
    if (category != null) query += 'AND category == "$category"';
    // and before some time (TIME NOT INCLUDED)
    if (beforeTime != null) {
      String beforeId = new Ulid(millis: beforeTime.microsecondsSinceEpoch)
          .toCanonical()
          .replaceRange(10, 25, '0' * 16);
      query += 'WHERE id < $beforeId';
    }
    // and after some time (TIME INCLUDED)
    if (beforeTime != null) {
      String afterId = new Ulid(millis: afterTime.microsecondsSinceEpoch)
          .toCanonical()
          .replaceRange(10, 25, '0' * 16);
      query += 'WHERE id < $afterId';
    }

    // execute!
    num = Sqflite.firstIntValue(await this._db.rawQuery(query));

    return num;
  }
}
