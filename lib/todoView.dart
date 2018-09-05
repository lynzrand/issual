import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';
import 'dart:async';
import 'dart:math';
import 'filerw.dart';

class IssualTodoView extends StatefulWidget {
  IssualTodoView(this.id, this.title, this._db);
  final String id;
  final String title;
  final Filerw _db;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoViewState(id, _db, title);
  }
}

class _IssualTodoViewState extends State<IssualTodoView> {
  _IssualTodoViewState(this.id, this._db, this.title) {
    this.init(id);
    this.creationTime = new DateTime.fromMillisecondsSinceEpoch(Ulid.parse(this.id).toMillis());
  }
  Future<void> init(String id) async {
    debugPrint('Initializing with Todo $id');
    var mainTodo = await _db.getTodoById(id);
    setState(() {
      this.mainTodo = mainTodo;
      this.loaded = true;
    });
  }

  String id;
  Filerw _db;
  bool loaded = false;
  String title;
  Todo mainTodo;
  DateTime creationTime = DateTime.now();

  final emptyTodoDescription = 'This todo has no description.';

  String getReadableTimeRepresentation(DateTime time) {
    if (time == null) return 'at unknown time';
    Duration timeFromNow = DateTime.now().difference(time);
    if (timeFromNow.compareTo(Duration(minutes: 2)) < 0) {
      return 'just now';
    } else if (timeFromNow.compareTo(Duration(hours: 1)) < 0) {
      return '${timeFromNow.inMinutes} minutes ago';
    } else if (timeFromNow.compareTo(Duration(days: 1)) < 0) {
      return '${timeFromNow.inHours} hours ago';
    } else {
      return 'at ${time.year}-${time.month}-${time.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Use sliver stuff
    return new Scaffold(
        body: new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(),
        new SliverToBoxAdapter(
          child: new Container(
            child: Hero(
              tag: widget.id + 'title',
              child: Text(
                this.title,
                style: Theme.of(context).textTheme.display1,
              ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
        ),
        new SliverToBoxAdapter(
          child: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Text(
              'Created ${getReadableTimeRepresentation(this.creationTime)} | ${this.id}',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
        new SliverToBoxAdapter(
          child: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Text(
                this.loaded ? mainTodo.desc ?? emptyTodoDescription : emptyTodoDescription),
          ),
        ),
      ],
    ));
  }
}

class IssualTodoEditorView extends StatefulWidget {
  IssualTodoEditorView(this.isNew, this.rawTodo);
  final bool isNew;
  final Map<String, dynamic> rawTodo;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoEditorViewState(rawTodo);
  }
}

class _IssualTodoEditorViewState extends State<IssualTodoEditorView> {
  _IssualTodoEditorViewState(this.rawTodo) {
    this.rawTodo ??= {'state': 'open', 'category': 'todo'};
  }

  Map<String, dynamic> rawTodo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {'save': false}),
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.check),
            //  onPressed: () => debugPrint(rawTodo.toString()),
            onPressed: () => Navigator.pop(
                  context,
                  {'save': true, 'data': rawTodo, 'isNew': widget.isNew},
                ),
          ),
        ],
      ),
      body: new SingleChildScrollView(
        child: new Padding(
          padding: new EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              new TextField(
                key: new Key('titleField'),
                decoration:
                    InputDecoration(hintText: 'Title', isDense: false, border: InputBorder.none),
                style: Theme.of(context).textTheme.display1,
                onChanged: (String str) => rawTodo['title'] = str,
              ),
              new TextField(
                key: new Key('categoryField'),
                decoration:
                    InputDecoration(hintText: 'Category', isDense: false, border: InputBorder.none),
                onChanged: (String str) => rawTodo['category'] = str,
              ),
              new Container(
                constraints: new BoxConstraints(minHeight: 240.0),
                child: new TextField(
                  key: new Key('descField'),
                  decoration: InputDecoration(hintText: 'Description', border: InputBorder.none),
                  maxLines: null,
                  onChanged: (String str) => rawTodo['desc'] = str,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
