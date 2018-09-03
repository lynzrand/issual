import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import 'package:path/path.dart';

// enum TodoState { open, closed, active, pending, disabled }
String _filerwLogPrefix = "[FileRW]";

class Todo {
  /// Unique identifier of the todo
  /// Using a 26-digit ULID string.
  String id;

  /// Title of the Todo
  String title;

  /// State of the todo. Avaliable: Open, Closed, Active, Pending, Finished.
  // TodoState state;
  String state;

  /// Description of the todo. (I wish it is) Markdown compatible.
  String desc;

  /// Deadline of the todo.
  DateTime ddl;

  /// Tags
  List<String> tags;

  Todo({Map<String, dynamic> rawTodo, bool isNewTodo = false}) {
    rawTodo ??= new Map<String, dynamic>();

    if (isNewTodo || rawTodo['id'] == null)
      this.id = new Ulid().toCanonical();
    else
      this.id = rawTodo['id'];

    this.title = rawTodo['title'];
    this.state = rawTodo['state'];
    this.desc = rawTodo['desc'];
    debugPrint('[Todo] Creating new Todo $id out of ${rawTodo.toString()}');
  }

  void changeState(String state) {
    this.state = state;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = this.id;
    map['title'] = this.title;
    map['desc'] = this.desc;
    map['ddl'] = this.ddl;
    map['state'] = this.state.toString();
    // debugPrint('ToMap called on Todo $id');
    return map;
  }
}

class Filerw {
  Filerw({bool debug = false}) {
    if (debug)
      this._debug = true;
    else
      this._debug = false;
  }

  String _path;
  Database _db;
  bool _debug;
  bool _initialized = false;

  final String todolistTableName = 'Todolist';

  Database getdb() => this._db;
  void debugSetDb(Database db) => this._db = db;

  void _askForInitialization() {
    debugPrint('[FileRW] Use Filerw.init() to initialize database');
  }

  Future<void> init({bool deleteCurrentDatabase = false}) async {
    // Yeah I know this is deprecated but it is the only way dude =x=
    await Sqflite.devSetDebugModeOn(true);

    debugPrint('$_filerwLogPrefix FileRW initialization start.');
    var path = await getDatabasesPath();
    this._path = join(path, "todo.db");

    if (deleteCurrentDatabase) deleteDatabase(this._path);
    debugPrint('$_filerwLogPrefix Database path: ${this._path}');

    this._db = await openDatabase(this._path, version: 1, onCreate: (Database db, int v) async {
      debugPrint('$_filerwLogPrefix Created a database at ${this._path}');
      await db.transaction((txn) async {
        await txn.execute(
            'CREATE TABLE $todolistTableName ( id TEXT PRIMARY KEY, title TEXT, state TEXT, desc TEXT, ddl INTEGER, tags TEXT )');
      });
    });
    debugPrint('$_filerwLogPrefix FileRW initialized at ${this._path}.');

    int entries = await this.countTodos();
    debugPrint('$_filerwLogPrefix This database has $entries entries');
    this._initialized = true;
  }

  /// Get Todos within 3 monts OR is active
  Future<List<Todo>> getRecentTodos() async {
    // Check initialization status
    if (!this._initialized) this._askForInitialization();
    debugPrint('$_filerwLogPrefix Getting Recent Todos');
    String startID =
        new Ulid(millis: DateTime.now().subtract(new Duration(days: 92)).millisecondsSinceEpoch)
            .toCanonical()
            .replaceRange(11, 26, '0' * 16);
    List<Map<String, dynamic>> rawTodos = await this._db.query(todolistTableName,
        where: '"id" > "?" OR "state" == ? OR "state" == ?',
        whereArgs: [startID, 'active', 'pending'],
        // columns: ['id', 'title', 'state', 'ddl', 'tags'],
        limit: 90);
    // List<Todo> todos = rawTodos.map<Todo>((rawTodo) => new Todo(rawTodo: rawTodo));
    List<Todo> todos = [];
    for (Map<String, dynamic> todo in rawTodos) {
      todos.add(new Todo(rawTodo: todo));
    }
    debugPrint(todos.toString());
    return todos;
  }

  Future<int> countTodos(
      {String state, String category, DateTime beforeTime, DateTime afterTime}) async {
    int num = 0;
    // Count todos
    String query = 'SELECT COUNT(*) FROM $todolistTableName';
    // List<String>

    if (state != null || category != null || beforeTime != null || afterTime != null)
      query += "WHERE";
    // With specific state
    if (state != null) query += 'state == "$state"';
    // And specific category
    if (category != null) query += 'AND category == "$category"';
    // and before some time (TIME NOT INCLUDED)
    if (beforeTime != null) {
      String beforeId = new Ulid(millis: beforeTime.microsecondsSinceEpoch)
          .toCanonical()
          .replaceRange(11, 26, '0' * 16);
      query += 'AND id > $beforeId';
    }
    // and after some time (TIME INCLUDED)
    if (beforeTime != null) {
      String afterId = new Ulid(millis: afterTime.microsecondsSinceEpoch)
          .toCanonical()
          .replaceRange(11, 26, '0' * 16);
      query += 'AND id < $afterId';
    }

    // execute!
    num = Sqflite.firstIntValue(await this._db.rawQuery(query));
    num ??= 0;
    return num;
  }

  void _addTodo(Todo todo, Batch bat) {
    bat.insert(todolistTableName, todo.toMap());
  }

  /// Post one or more Todos into database
  Future<void> postTodo({
    Todo todo,
    List<Todo> todoList,
    Map<String, Todo> todoMap,
  }) async {
    if (todo == null && todoList == null && todoMap == null)
      throw ArgumentError(
          '$_filerwLogPrefix Filerw.postTodo expected todo, todoList or todoMap to present!');
    var bat = _db.batch();

    debugPrint('$_filerwLogPrefix asked to post Todos with ${bat.toString()}');
    if (todo != null) {
      this._addTodo(todo, bat);
    }
    if (todoList != null) {
      for (Todo oneTodo in todoList) this._addTodo(oneTodo, bat);
    }
    if (todoMap != null) {
      for (String todoMapKey in todoMap.keys) this._addTodo(todoMap[todoMapKey], bat);
    }

    await bat.commit(noResult: true);
  }

  Future<Todo> getTodoById(String id) async {
    Todo todo;
    todo = (await this._db.query(todolistTableName, where: 'id == "$id"'))[0] as Todo;
    return todo;
  }

  void _removeTodo(String id, Batch bat) {
    bat.delete(todolistTableName, where: 'id == ?', whereArgs: [id]);
  }

  Future<void> removeTodo({String id, List<String> ids}) {
    if (id == null && ids == null)
      throw ArgumentError('$_filerwLogPrefix Filerw.RemoveTodo expected id or ids to present!');

    Batch bat = _db.batch();
    if (id != null) {
      _removeTodo(id, bat);
    }
    if (ids != null) {
      ids.forEach((oneId) => _removeTodo(oneId, bat));
    }
    bat.commit();
  }
}
