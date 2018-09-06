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

  /// Group / Category
  String category;

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
    this.desc = rawTodo['desc'] == "" ? null : rawTodo['desc'];
    this.tags = rawTodo['tags'] == null ? null : (rawTodo['tags'] as String).split('+');
    this.category = rawTodo['category'];
    debugPrint('[Todo] Creating new Todo $id out of ${rawTodo.toString()}');
  }

  void changeState(String state) {
    this.state = state;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = this.id;
    map['title'] = this.title;
    map['desc'] = this.desc == '' ? null : this.desc;
    // if(this.desc == "") map['desc'] = null;
    map['ddl'] = this.ddl;
    map['tags'] = this.tags == null ? null : this.tags.join('+');
    map['category'] = this.category;
    map['state'] = this.state;
    // debugPrint('ToMap called on Todo $id');
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}

class Filerw {
  String _path;
  Database _db;
  bool _initialized = false;

  final String todolistTableName = 'Todolist';
  final String categoryTableName = 'Categories';

  List<String> categories = [];

  Database getdb() => this._db;
  void debugSetDb(Database db) => this._db = db;

  void _askForInitialization() {
    debugPrint('[FileRW] Use Filerw.init() to initialize database');
  }

  Future<void> init({bool deleteCurrentDatabase = false}) async {
    // Yeah I know this is deprecated but it is the only way dude =x=
    // await Sqflite.devSetDebugModeOn(true);

    debugPrint(
        '$_filerwLogPrefix FileRW initialization start. ${deleteCurrentDatabase ? "DELETING CURRENT DATABASE" : ""}');
    var path = await getDatabasesPath();
    this._path = join(path, "todo.db");

    if (deleteCurrentDatabase) {
      await deleteDatabase(this._path);
    }

    debugPrint('$_filerwLogPrefix Database path: ${this._path}');

    this._db = await openDatabase(this._path, version: 3, onCreate: (Database db, int v) async {
      debugPrint('$_filerwLogPrefix Created a database at ${this._path}');
      await db.transaction((txn) async {
        await txn.execute(
            'CREATE TABLE $todolistTableName ( id TEXT PRIMARY KEY, title TEXT, state TEXT, desc TEXT, ddl INTEGER, tags TEXT, category TEXT NOT NULL )');
        await txn.execute(
            'CREATE TABLE $categoryTableName ( id INTEGER AUTO INCREMENT PRIMARY KEY, category TEXT UNIQUE NOT NULL)');
        await txn.insert(todolistTableName, {
          'id': '00000000000000000000000000',
          'title': 'Hey, there!',
          'category': 'todo',
          'state': 'active',
        });
        await txn.insert(categoryTableName, {'category': 'todo'});
      });
    }, onUpgrade: (Database db, int oldv, int newv) async {
      if (oldv == 1 && newv == 2) {
        await db.execute('ALTER TABLE $todolistTableName ADD COLUMN category TEXT');
        await db.update(todolistTableName, {'category': 'todo'}, where: 'category IS NULL');
        oldv = 2;
      }
      if (oldv == 2 && newv == 3) {
        // TODO: ADD NEW table to manage categories!
        await db.execute(
            'CREATE TABLE $categoryTableName ( id INTEGER AUTO INCREMENT PRIMARY KEY, category TEXT )');
        await db.rawInsert(
            'INSERT INTO $categoryTableName ("category") SELECT DISTINCT ("category") FROM $todolistTableName');
        oldv = 3;
      }

      this.categories = await getCategories();
    });
    debugPrint('$_filerwLogPrefix FileRW initialized at ${this._path}.');

    int entries = await this.countTodos();
    debugPrint('$_filerwLogPrefix This database has $entries entries');
    this._initialized = true;
  }

  /// Get Todos within 3 monts OR is active
  ///
  /// Returns Map< category: String, List< Todo > >
  Future<Map<String, List<Todo>>> getRecentTodos() async {
    // Check initialization status
    if (!this._initialized) this._askForInitialization();
    debugPrint('$_filerwLogPrefix Getting Recent Todos');
    String startID =
        new Ulid(millis: DateTime.now().subtract(new Duration(days: 92)).millisecondsSinceEpoch)
            .toCanonical()
            .replaceRange(11, 26, '0' * 16);
    List<Map<String, dynamic>> rawTodos = await this._db.query(todolistTableName,
        // Disabling limits in order to aid development
        // where: '"id" > ? OR "state" == ? OR "state" == ?',
        // whereArgs: [startID, 'active', 'pending'],
        columns: ['id', 'title', 'state', 'ddl', 'tags', 'category'],
        // limit: 90,
        orderBy: 'id DESC');
    // List<Todo> todos = rawTodos.map<Todo>((rawTodo) => new Todo(rawTodo: rawTodo));
    Map<String, List<Todo>> todos = {};
    for (Map<String, dynamic> todo in rawTodos) {
      if (todos[todo['category'].toString()] == null) todos[todo['category'].toString()] = [];
      todos[todo['category'].toString()].add(new Todo(rawTodo: todo));
    }
    // This is not the best way to do...
    await flashCategories();
    return todos;
  }

  Future<bool> wipeDatabase() async {
    debugPrint('$_filerwLogPrefix WIPING OUT THE ENTIRE DATABASE!');
    await _db.delete(todolistTableName);
    await _db.delete(categoryTableName);
    await _db.insert(todolistTableName, {
      'id': '00000000000000000000000000',
      'title': 'Hey, there!',
      'category': 'todo',
      'state': 'active',
    });
    await _db.insert(categoryTableName, {'category': 'todo'});
    debugPrint('$_filerwLogPrefix SUCCESSFULLY DELETED ALL ENTRIES.');
    return true;
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
    if (todo.category != null) {
      debugPrint('$_filerwLogPrefix Adding ${todo.id} to batch');
      bat.insert(todolistTableName, todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      throw Exception('Category of Todo ${todo.id} is null!');
    }
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

    if (todo != null) {
      this._addTodo(todo, bat);
    }
    if (todoList != null) {
      for (Todo oneTodo in todoList) this._addTodo(oneTodo, bat);
    }
    if (todoMap != null) {
      for (String todoMapKey in todoMap.keys) this._addTodo(todoMap[todoMapKey], bat);
    }

    debugPrint('$_filerwLogPrefix commiting batch');
    await bat.commit(noResult: true);
    await flashCategories();
  }

  Future<Todo> getTodoById(String id) async {
    Todo todo;
    todo = Todo(rawTodo: (await this._db.query(todolistTableName, where: 'id == "$id"'))[0]);
    return todo;
  }

  void _removeTodo(String id, Batch bat) {
    debugPrint('$_filerwLogPrefix Adding removal of $id to batch');
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

  Future<void> updateTodo(String id, Todo newTodo) async {
    assert(id != null);
    await _db.update(todolistTableName, newTodo.toMap(), where: 'id == ?', whereArgs: [id]);
  }

  /// Flash categories with unique selections from TodoList.
  /// Useful when Todolist has more categories than Categories
  Future<void> flashCategories() async {
    await _db.rawInsert(
        'INSERT OR REPLACE INTO $categoryTableName ("category") SELECT DISTINCT ("category") FROM $todolistTableName');
  }

  Future<void> flashCategoriesWithBatch(Batch bat) async {
    bat.rawInsert(
        'INSERT OR REPLACE INTO $categoryTableName ("category") SELECT DISTINCT ("category") FROM $todolistTableName');
  }

  Future<List<String>> getCategories() async {
    // await flashCategories();
    var rawCategories = await _db.query(categoryTableName, columns: ['category']);
    List<String> categories = [];
    for (var raw in rawCategories) categories.add(raw['category'].toString());
    debugPrint('Categories: ${categories.toString()}');
    return categories;
  }

  Future<void> addCategory(String cat) async {
    await _db.insert(categoryTableName, {'category': cat},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
