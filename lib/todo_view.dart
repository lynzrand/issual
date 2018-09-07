import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'style.dart';
import 'filerw.dart';
import 'notifications.dart';

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
    this.mainTodo = Todo(
        isNewTodo: false, rawTodo: {'id': this.id, 'title': this.title, 'state': '', 'desc': ''});
    this.creationTime = new DateTime.fromMillisecondsSinceEpoch(Ulid.parse(this.id).toMillis());
    this.init(id);
  }
  Future<void> init(String id) async {
    debugPrint('Initializing with Todo $id');
    var mainTodo;
    try {
      mainTodo = await _rw.getTodoById(id);
    } catch (e) {
      debugPrint(e);
    }
    setState(() {
      if (mainTodo != null) this.mainTodo = mainTodo;
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

  void postEdit() {
    Navigator.push(
      context,
      IssualTransitions.verticlaPageTransition(
        (BuildContext context, ani1, ani2) =>
            new IssualTodoEditorView(false, mainTodo.toMap(), _rw),
      ),
    ).then((_) => this.init(id));
  }

  bool notificationHandler(Notification t) {
    if (t is TodoTagNotification) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Use sliver stuff
    return new Scaffold(
      body: new NotificationListener(
        onNotification: notificationHandler,
        child: new CustomScrollView(
          slivers: <Widget>[
            // Appbar
            new SliverAppBar(
              pinned: true,
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

            // Title
            new SliverToBoxAdapter(
              child: new Container(
                child: Hero(
                  tag: widget.id + 'title',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      this.title,
                      style: Theme.of(context).textTheme.headline,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
              ),
            ),

            // Status, creation time and ID
            new SliverToBoxAdapter(
              child: new Container(
                padding: EdgeInsets.all(8.0),
                child: new Row(
                  children: [
                    new Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: IssualMisc.getColorForStateDesaturated(context, mainTodo.state),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Text(
                        mainTodo.state.toUpperCase(),
                        style: Theme.of(context).textTheme.body2.apply(
                              color:
                                  IssualMisc.getColorForStateDesaturated(context, mainTodo.state),
                            ),
                      ),
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          'Created ' + IssualMisc.getReadableTimeRepresentation(creationTime, true),
                          style: Theme.of(context).textTheme.caption,
                        ),
                        new Text(
                          mainTodo.id,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tags
            new SliverToBoxAdapter(
              child: new Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: new Wrap(
                    spacing: 8.0,
                    children: List.generate(
                      (mainTodo.tags != null ? mainTodo.tags.length : 0) + 1,
                      (index) {
                        if (index == 0)
                          return ActionChip(
                            label: Text('Add'),
                            avatar: Icon(
                              Icons.add,
                              size: 16.0,
                            ),
                            onPressed: () => {},
                          );
                        else
                          return ActionChip(
                            label: Text(mainTodo.tags[index - 1]),
                            onPressed: () => {},
                          );
                      },
                    ),
                  )),
            ),

            // Description
            new SliverToBoxAdapter(
              child: new Container(
                padding: EdgeInsets.all(16.0),
                child: new MarkdownBody(
                  data: this.loaded ? mainTodo.desc ?? emptyTodoDescription : emptyTodoDescription,
                  onTapLink: (linkText) {
                    canLaunch(linkText).then((result) => launch(linkText));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    if (this.rawTodo != null) {
      this.rawTodo['state'] ??= 'open';
      this.rawTodo['category'] ??= TodoCategory(name: 'Todo', color: 'blue');

      titleController = new TextEditingController(text: rawTodo['title'] as String);
      categoryController =
          new TextEditingController(text: (rawTodo['category'] as TodoCategory).name);
    } else {
      titleController = new TextEditingController();
      categoryController = new TextEditingController();
    }
    if (this.rawTodo != null)
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
      {'save': true},
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

          // Title
          new SliverToBoxAdapter(
            child: new Padding(
              padding: new EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                tag: (widget.rawTodo != null ? widget.rawTodo['id'] : 'empty') + 'title',
                child: new Material(
                  color: Colors.transparent,
                  child: TextField(
                    key: new Key('titleField'),
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                        hintText: 'Title', isDense: false, border: InputBorder.none),
                    style: Theme.of(context).textTheme.headline,
                    onChanged: (String str) => rawTodo['title'] = str,
                  ),
                ),
              ),
            ),
          ),

          // TODO: replace this with a horizontal scroller with categoty chips
          //        so that one cannot leave it blank
          new SliverToBoxAdapter(
            child: new Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child:
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
            ),
          ),

          // Tags
          new SliverToBoxAdapter(
            child: new Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: new Wrap(
                  spacing: 8.0,
                  children: List.generate(
                    // TODO: getTopTags()!
                    5,
                    (index) {
                      if (index == 0)
                        return ActionChip(
                          label: Text('Add'),
                          avatar: Icon(
                            Icons.add,
                            size: 16.0,
                          ),
                          onPressed: () => {},
                        );
                      else
                        return FilterChip(
                          label: Text(index.toString()),
                          onSelected: (selected) =>
                              debugPrint('$index has been ${selected ? '' : 'un'}selected'),
                        );
                    },
                  ),
                )),
          ),

          new SliverToBoxAdapter(
            child: new Container(
              constraints: new BoxConstraints(minHeight: 240.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: new TextField(
                key: new Key('descField'),
                controller: descController,
                decoration: InputDecoration(hintText: 'Description', border: InputBorder.none),
                maxLines: null,
                onChanged: (String str) => rawTodo['desc'] = str,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
