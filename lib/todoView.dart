import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';
import 'style.dart';
import 'dart:async';
import 'dart:math';
import 'filerw.dart';

class IssualTodoView extends StatefulWidget {
  IssualTodoView(this.id, this.title, this._rw);
  final String id;
  final String title;
  final Filerw _rw;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoViewState(id, _rw, title);
  }
}

class _IssualTodoViewState extends State<IssualTodoView> {
  _IssualTodoViewState(this.id, this._rw, this.title) {
    this.init(id);
    this.creationTime = new DateTime.fromMillisecondsSinceEpoch(Ulid.parse(this.id).toMillis());
  }
  Future<void> init(String id) async {
    debugPrint('Initializing with Todo $id');
    var mainTodo = await _rw.getTodoById(id);
    setState(() {
      this.mainTodo = mainTodo;
      this.loaded = true;
    });
  }

  String id;
  Filerw _rw;
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
    } else if (timeFromNow.compareTo(Duration(hours: 2)) < 0) {
      return '${timeFromNow.inMinutes + timeFromNow.inHours * 60} minutes ago';
    } else if (timeFromNow.compareTo(Duration(days: 1)) < 0) {
      return '${timeFromNow.inHours} hours ago';
    } else {
      return 'at ${time.year}-${time.month}-${time.day}';
    }
  }

  void postEdit() {
    Navigator.push(
      context,
      IssualTransitions.verticlaPageTransition(
        (BuildContext context, ani1, ani2) => new IssualTodoEditorView(false, mainTodo.toMap(), _rw),
      ),
    ).then((_) => this.init(id));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Use sliver stuff
    return new Scaffold(
        body: new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.edit),
              onPressed: postEdit,
            ),
            new PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: '',
                      child: Text('Placeholder'),
                    )
                  ],
            )
          ],
        ),
        new SliverToBoxAdapter(
          child: new Container(
            child: Hero(
              tag: widget.id + 'title',
              child: Text(this.title, style: Theme.of(context).textTheme.headline),
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
  IssualTodoEditorView(this.isNew, this.rawTodo, this.rw);
  final bool isNew;
  final Map<String, dynamic> rawTodo;
  final Filerw rw;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoEditorViewState(rawTodo, rw);
  }
}

class _IssualTodoEditorViewState extends State<IssualTodoEditorView> {
  _IssualTodoEditorViewState(this.rawTodo, this.rw) {
    this.rawTodo ??= {'state': 'open', 'category': 'todo'};
    titleController = new TextEditingController(text: rawTodo['title'] as String);
    categoryController = new TextEditingController(text: rawTodo['category'] as String);
    if (this.rawTodo['id'] != null)
      rw.getTodoById(this.rawTodo['id']).then((data) {
        setState(() {
          this.rawTodo = data.toMap();
          descController = new TextEditingController(text: rawTodo['desc'] as String);
        });
      });
  }

  Map<String, dynamic> rawTodo;
  Filerw rw;

  TextEditingController titleController;
  TextEditingController categoryController;
  TextEditingController descController;

  void exitWithSaving() async {
    Todo todo = new Todo(
      rawTodo: rawTodo,
      isNewTodo: widget.isNew,
    );
    if (widget.isNew)
      await rw.postTodo(todo: todo);
    else
      await rw.updateTodo(todo.id, todo);

    Navigator.pop(
      context,
      {'save': true, 'data': rawTodo, 'isNew': widget.isNew},
    );
  }

  void exitWithoutSaving() {
    Navigator.pop(context, {'save': false});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            leading: new IconButton(
              icon: new Icon(Icons.close),
              onPressed: exitWithoutSaving,
            ),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.check),
                //  onPressed: () => debugPrint(rawTodo.toString()),
                onPressed: exitWithSaving,
              ),
            ],
            pinned: true,
          ),
          new SliverToBoxAdapter(
            child: new Padding(
              padding: new EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  new TextField(
                    key: new Key('titleField'),
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'Title', isDense: false, border: InputBorder.none),
                    style: Theme.of(context).textTheme.headline,
                    onChanged: (String str) => rawTodo['title'] = str,
                  ),
                  // TODO: replace this with a horizontal scroller with categoty chips
                  //        so that one cannot leave it blank

                  // TODO: ADD tag selector
                  new TextField(
                    key: new Key('categoryField'),
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: 'Category',
                      isDense: false,
                      border: InputBorder.none,
                      prefixText: 'iL/',
                    ),
                    onChanged: (String str) => rawTodo['category'] = str,
                  ),
                  new Container(
                    constraints: new BoxConstraints(minHeight: 240.0),
                    child: new TextField(
                      key: new Key('descField'),
                      controller: descController,
                      decoration:
                          InputDecoration(hintText: 'Description', border: InputBorder.none),
                      maxLines: null,
                      onChanged: (String str) => rawTodo['desc'] = str,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
