import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'filerw.dart';
import 'dart:math';
import './style.dart';
import './search_screen.dart';
import './todo_view.dart';
import './notifications.dart';

void main() {
  runApp(new IssualHome());
}

class IssualHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Issual',
      theme: IssualColors.issualMainTheme,
      home: new MyHomePage(title: 'Issual'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final ScrollController homeScrlCtrl = new ScrollController();

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    this._rw = new Filerw();
    this._rw.init().then(this.init);
  }
  Future<void> init(_) async {
    _rw.getRecentTodos().then((Map<String, List<Todo>> todosGot) {
      _rw.getCategories().then((List<String> categories) {
        setState(() {
          this.categories = categories;
          this.displayedTodos = todosGot;

          this._rwInitialized = true;
          debugPrint(categories.toString());
        });
      }, onError: (e) {
        debugPrint(e.toString());
      });
    }, onError: (e) {
      debugPrint(e.toString());
    });
  }

  bool foundEasterEgg = false;
  Filerw _rw;
  bool _rwInitialized = false;
  Map<String, List<Todo>> displayedTodos = {};
  List<String> categories = [];

  /// Handles ALL notifications bubbling up the app.
  /// TODO: Intercept some notifications midway if needed.
  bool _notificationHandler(Notification t) {
    debugPrint(t.toString());

    // BROKEN CODE! FIXME:
    //
    // if (t is UserScrollNotification) {
    //   double toScroll = widget.homeScrlCtrl.position.maxScrollExtent -
    //       widget.homeScrlCtrl.position.viewportDimension +
    //       360;
    //   double offset = widget.homeScrlCtrl.offset;
    //   // debugPrint('Notification at $offset; To match: $toScroll');
    //   /*
    //    * FIXME: The following assertion was thrown while handling a gesture:
    //    * 'package:flutter/src/widgets/scrollable.dart': Failed assertion:
    //    * line 445 pos 12: '_hold == null': is not true.
    //    *
    //    * TODO: replace this with ScrollPhysics if possible!
    //    * Note: This bug DOES NOT affect release versions of the app.
    //    *
    //    * An issue has already been posted on Github at
    //    * https://github.com/flutter/flutter/issues/14452.
    //    * No official fixes has been released though.
    //    * USE WITH CAUTION!
    //    */
    //   if (toScroll < offset && widget.homeScrlCtrl.position.maxScrollExtent - offset >= 120.0) {
    //     widget.homeScrlCtrl.animateTo(
    //       toScroll,
    //       duration: new Duration(milliseconds: 250),
    //       curve: Curves.easeOut,
    //     );
    //     debugPrint('Hiding Scroll fired @$offset');
    //     setState(() {
    //       foundEasterEgg = false;
    //     });
    //   } else if (widget.homeScrlCtrl.position.maxScrollExtent - offset < 120.0 &&
    //       widget.homeScrlCtrl.position.maxScrollExtent - offset > 0) {
    //     widget.homeScrlCtrl.animateTo(
    //       widget.homeScrlCtrl.position.maxScrollExtent,
    //       duration: new Duration(milliseconds: 125),
    //       curve: Curves.easeOut,
    //     );
    //     setState(() {
    //       foundEasterEgg = true;
    //     });
    //     return true;
    //   } else if (widget.homeScrlCtrl.position.maxScrollExtent - offset == 0) {
    //     setState(() {
    //       foundEasterEgg = true;
    //     });
    //   } else {
    //     setState(() {
    //       foundEasterEgg = false;
    //     });
    //   }
    //   return true;
    // } else
    if (t is TodoStateChangeNotification) {
      switch (t.stateChange) {

        /// FLIP: flip Todo's state
        /// e.g.
        ///   open, active, pending => closed
        ///   closed, canceled => open
        case TodoStateChangeType.flip:
          // TODO: implement FLIP
          Todo todo = t.data['todo'] as Todo;
          // setState() called at TodoListItem
          // this.setState(() {
          //   displayedTodos[todo.category][t.data['index']].state = t.data['state'];
          // });
          todo.state = t.data['state'];
          _rw.updateTodo(todo.id, todo);
          break;

        /// ADD: add Todo in t.data to database
        case TodoStateChangeType.add:
          this.setState(() {
            this.displayedTodos[t.data.category] ??= [];
            this.displayedTodos[t.data.category].insert(0, t.data as Todo);
          });
          _rw.postTodo(todo: t.data as Todo);
          break;

        /// VIEW: navigate to Todo whose id == t.id
        case TodoStateChangeType.view:
          Navigator.push(
            context,
            IssualTransitions.verticlaPageTransition(
              (context, ani1, ani2) {
                return new IssualTodoView(t.id, t.data as String, _rw);
              },
            ),
          );
          break;

        /// REMOVE: delete this Todo item.
        case TodoStateChangeType.remove:
          setState(() {
            displayedTodos[(t.data['todo'] as Todo).category].removeAt(t.data['index']);
          });
          _rw.removeTodo(id: t.id);
          break;

        /// WIPE: DANGEROUS Wipe out the whole database
        case TodoStateChangeType.wipe:
          _rw.init(deleteCurrentDatabase: true).then(this.init);
          break;
      }
      return true;
    } else if (t is TodoEditNotification) {
      Navigator.push(
        context,
        IssualTransitions.verticlaPageTransition(
          (BuildContext context, ani1, ani2) => new IssualTodoEditorView(t.newTodo, t.rawTodo, _rw),
        ),
      ).then((dynamic data) async {
        await this.init(null);
      }).catchError((e) => debugPrint(e));
      return true;
    } else if (t is TodoCategoryChangeNotification) {}
  }

  Widget _buildTodoCard(BuildContext ctx, int index) {
    if (!this._rwInitialized)
      return null;
    else
      return new TodoCard(
        title: categories[index].toString(),
        todos: displayedTodos[categories[index].toString()],
      );
  }

// UI
  @override
  Widget build(BuildContext context) {
    return new NotificationListener(
      onNotification: _notificationHandler,
      child: new Scaffold(
        body: new CustomScrollView(
          slivers: <Widget>[
            new IssualAppBar(_rwInitialized),
            new SliverToBoxAdapter(child: new IssualDebugInfoCard(rwInitialized: _rwInitialized)),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(this._buildTodoCard,
                  childCount: categories.length),
            ),
            new SliverToBoxAdapter(child: IssualNewCategoryButton()),
            // new SliverFillRemaining(),
            new SliverFillRemaining(
              child: new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.0),
                // TODO: show REAL easter eggs!
                child: new Text(
                  'Nothing more to show (￣▽￣)"',
                ),
              ),
            ),
          ],
          controller: widget.homeScrlCtrl,
        ),
        // new Column(
        //   children: <Widget>[
        //     new TodoCard(
        //       title: "Todos",
        //     )
        //   ],
        // ),
        floatingActionButton: new IssualFAB(),
      ),
    );
  }
}

class IssualAppBar extends StatefulWidget {
  IssualAppBar(this.databaseLoaded);
  final bool databaseLoaded;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualAppBarState();
  }
}

class _IssualAppBarState extends State<IssualAppBar> {
  @override
  Widget build(BuildContext context) {
    return new SliverAppBar(
      pinned: true,
      expandedHeight: 360.0,
      title: new Text(
        'iL/all_todos',
      ),
      flexibleSpace: new FlexibleSpaceBar(
        background: Container(
          // TODO: show real data!
          alignment: Alignment.center,
          child: Text('=v='),
        ),
      ),
      actions: <Widget>[
        new IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IssualSearchScreen()));
          },
        )
      ],
    );
  }
}

class TodoCard extends StatelessWidget {
  TodoCard({Key key, this.title, this.todos}) : super(key: key);

  final String title;
  final List<Todo> todos;
  final Map<String, dynamic> themeColors = IssualColors.coloredThemes['blue'];

  @override
  Widget build(BuildContext context) {
    return Theme(
      key: new Key('cardTheme#$title'),
      data: Theme.of(context).copyWith(
        primaryColor: themeColors['primarySwatch'],
        accentColor: themeColors['accentColor'],
      ),
      child: new Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.all(16.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new Text(
                    '$title'.toUpperCase(),
                    style: Theme.of(context).textTheme.title.apply(
                          color: (themeColors['primarySwatch'] as MaterialColor).shade800,
                        ),
                  )),
                  // new IconButton(
                  //   icon: new Icon(Icons.expand_less),
                  //   onPressed: null,
                  // ),
                ],
              ),
            ),
            new Column(
              children: List.generate(todos == null ? 1 : todos.length, (int index) {
                if (todos == null)
                  return new Container(
                    height: 96.0,
                    alignment: Alignment.center,
                    child: new Text('This category currently has no Todos'),
                  );
                else
                  return new TodoListItem(todos[index], index, key: Key(todos[index].id));
              }),
            ),
            new ButtonBar(
              children: <Widget>[
                // new IconButton(
                //   icon: new Icon(Icons.add),
                //   onPressed: null,
                // )
                new IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => TodoEditNotification(rawTodo: {'category': title}, newTodo: true)
                      .dispatch(context),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListItem extends StatefulWidget {
  TodoListItem(final this.todo, this.index, {Key key}) : super(key: key);

  // TODO: move this to filerw.dart/todo

  final Todo todo;
  final int index;
  @override
  State<StatefulWidget> createState() {
    return new _TodoListItemState(todo.state, todo.id);
  }
}

class _TodoListItemState extends State<TodoListItem> {
  // TodoState state;
  _TodoListItemState(this.state, this.id);
  String state;
  final String id;

  void flipState() {
    setState(() {
      switch (state) {
        case 'open':
          state = 'active';
          break;
        case 'closed':
        case 'canceled':
          state = 'open';
          break;
        case 'active':
        case 'pending':
        default:
          state = 'closed';
          break;
      }
    });

    TodoStateChangeNotification(
      id: widget.todo.id,
      stateChange: TodoStateChangeType.flip,
      data: {'todo': widget.todo, 'index': widget.index, 'state': state},
    ).dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragEnd: (dragDetail) {
        if (dragDetail.primaryVelocity > 0) flipState();
      },
      child: InkWell(
        splashColor: IssualColors.darkColorRipple,
        // TODO: onTap: emit a notification up the tree!
        onTap: () {
          TodoStateChangeNotification(
            id: widget.todo.id,
            stateChange: TodoStateChangeType.view,
            data: widget.todo.title,
          ).dispatch(context);
        },
        child: new Row(
          children: <Widget>[
            new IconButton(
              icon: new Icon(
                IssualMisc.stateIcons[state],
                color: IssualMisc.getColorForState(context, state),
              ),
              onPressed: () => flipState(),
              tooltip: 'Flip Todo state',
            ),
            new Expanded(
              child: new Hero(
                tag: this.widget.todo.id + 'title',
                child: new Text(
                  this.widget.todo.title ?? '#${this.widget.todo.id}',
                  style: IssualMisc.getTodoTextStyle(context, state),
                ),
              ),
            ),
            new PopupMenuButton(
              icon: new Icon(Icons.more_horiz),
              // itemBuilder: ,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'remove',
                    child:
                        // new Row(children: [new Icon(Icons.delete),
                        Text('Remove'),
                    //  ]),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child:
                        // new Row(children: [new Icon(Icons.edit),
                        new Text('Edit'),
                    //  ]),
                  )
                ];
              },
              onSelected: (dynamic item) {
                switch (item as String) {
                  case 'remove':
                    TodoStateChangeNotification(
                        id: widget.todo.id,
                        stateChange: TodoStateChangeType.remove,
                        data: {'todo': widget.todo, 'index': widget.index}).dispatch(context);
                    break;
                  case 'edit':
                    TodoEditNotification(rawTodo: widget.todo.toMap()).dispatch(context);
                    break;
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class IssualFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: () {
        // TODO: implement REAL adding
        TodoEditNotification(newTodo: true).dispatch(context);
      },
    );
  }
}

class IssualNewCategoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.all(16.0),
      height: 48.0,
      child: new RaisedButton.icon(
        icon: Icon(Icons.add),
        label: Text('Add Category'),
        onPressed: () =>
            TodoCategoryChangeNotification(type: TodoCategoryChangeType.add).dispatch(context),
        color: Theme.of(context).accentColor,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}

class IssualDebugInfoCard extends StatelessWidget {
  IssualDebugInfoCard({this.rwInitialized});

  final bool rwInitialized;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: Text('Database Loaded: $rwInitialized'),
              onLongPress: () async {
                var result = await showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                        title: Text('Wipe the database?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('NO'),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          FlatButton(
                            child: Text('YES'),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                );
                if (result)
                  TodoStateChangeNotification(stateChange: TodoStateChangeType.wipe)
                      .dispatch(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
