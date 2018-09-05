import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'filerw.dart';
import 'dart:math';
import './style.dart';
import './searchScreen.dart';
import './todoView.dart';
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
        case 'flip':
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
        case 'add':
          this.setState(() {
            this.displayedTodos[t.data.category] ??= [];
            this.displayedTodos[t.data.category].insert(0, t.data as Todo);
          });
          _rw.postTodo(todo: t.data as Todo);
          break;

        /// VIEW: navigate to Todo whose id == t.id
        case 'view':
          Navigator.push(
            context,
            new PageRouteBuilder(
              pageBuilder: (context, ani1, ani2) {
                return new IssualTodoView(t.id, t.data as String, _rw);
              },
              transitionsBuilder: (context, ani1_, ani2, Widget child) {
                var ani1 = CurvedAnimation(curve: Curves.easeOut, parent: ani1_);
                return new FadeTransition(
                  opacity: ani1,
                  child: new SlideTransition(
                    position: Tween(begin: Offset(0.0, 0.2), end: Offset(0.0, 0.0)).animate(ani1),
                    child: child,
                  ),
                );
              },
            ),
            // MaterialPageRoute(
            //   builder: (context) {
            //     return new IssualTodoView(t.id, t.data as String, _rw);
            //   },
            // ),
          );
          break;

        /// REMOVE: delete this Todo item.
        case 'remove':
          setState(() {
            displayedTodos[(t.data['todo'] as Todo).category].removeAt(t.data['index']);
          });
          _rw.removeTodo(id: t.id);
          break;

        /// WIPE: DANGEROUS Wipe out the whole database
        case 'wipe':
          _rw.init(deleteCurrentDatabase: true).then(this.init);
          break;
      }
      return true;
    } else if (t is TodoEditNotification) {
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new IssualTodoEditorView(t.newTodo, t.rawTodo),
          fullscreenDialog: true,
        ),
      ).then((dynamic data) async {
        var structuredData = data as Map<String, dynamic>;
        structuredData ??= {};
        if (structuredData['save'] == false || structuredData['save'] == null) return;

        Todo todo = new Todo(
          rawTodo: structuredData['data'],
          isNewTodo: structuredData['isNew'] as bool,
        );
        if (structuredData['isNew'] as bool)
          await _rw.postTodo(todo: todo);
        else
          await _rw.updateTodo(structuredData['data']['id'], todo);

        if (categories.indexOf(todo.category) < 0) await _rw.addCategory(todo.category);

        await this.init(null);
      });
      return true;
    }
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
            new SliverFillRemaining(
              child: new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.0),
                // TODO: show REAL easter eggs!
                child: new Text(
                  foundEasterEgg
                      ? "You found an Easter Egg!"
                      : "That's all. What are you expecting?",
                  style: new TextStyle(
                    color: new Color(0xffffffff),
                  ),
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
        drawer: new Drawer(
          child: new Text(
            "data",
          ),
        ),
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
      flexibleSpace: new FlexibleSpaceBar(
        background: Container(
          // TODO: show real data!
          alignment: Alignment.center,
        ),
        title: new Text(
          'iL/all_todos',
          style: TextStyle(fontWeight: FontWeight.w400),
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
  final ThemeData themeData = IssualColors.coloredThemes['red'];

  @override
  Widget build(BuildContext context) {
    return Theme(
      key: new Key('cardTheme'),
      data: themeData,
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
                    style: TextStyle(
                      color: themeData.primaryColor,
                      fontSize: Theme.of(context).textTheme.title.fontSize,
                      fontWeight: FontWeight.bold,
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
              children: List.generate(todos.length, (int index) {
                return new TodoListItem(todos[index], index);
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
                  onPressed: () => {},
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
  TodoListItem(final this.todo, this.index);

  // TODO: move this to filerw.dart/todo
  static const stateIcons = <String, IconData>{
    'open': Icons.radio_button_unchecked,
    'closed': Icons.check_circle_outline,
    'pending': Icons.access_time,
    'active': Icons.data_usage,
    'canceled': Icons.remove_circle_outline,
  };

  final Todo todo;
  final int index;

  @override
  State<StatefulWidget> createState() {
    return new _TodoListItemState(todo.state);
  }
}

class _TodoListItemState extends State<TodoListItem> {
  // TodoState state;
  _TodoListItemState(this.state);
  String state;

  Color getIconColor(BuildContext context, String state) {
    final theme = Theme.of(context);
    switch (state) {
      case 'open':
        return theme.primaryColor;
        break;
      case 'closed':
      case 'finished':
        return theme.disabledColor;
        break;
      case 'active':
      case 'pending':
        return theme.accentColor;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      splashColor: IssualColors.darkColorRipple,
      // TODO: onTap: emit a notification up the tree!
      onTap: () {
        TodoStateChangeNotification(
                id: widget.todo.id, stateChange: 'view', data: widget.todo.title)
            .dispatch(context);
      },
      child: new Row(
        children: <Widget>[
          new IconButton(
              icon: new Icon(
                TodoListItem.stateIcons[state],
                color: getIconColor(context, state),
              ),
              onPressed: () {
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
                  stateChange: 'flip',
                  data: {'todo': widget.todo, 'index': widget.index, 'state': state},
                ).dispatch(context);
              }),
          new Expanded(
            child:
                // TODO: Really, show tags?
                //
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                new Hero(
              tag: this.widget.todo.id + 'title',
              child: new Text(
                this.widget.todo.title ?? '#${this.widget.todo.id}',
                style: IssualColors.getTodoTextStyle(context, state),
              ),
            ),
            // new Wrap(
            //   children: <Widget>[
            //     new Chip(
            //       label: Text("Tag"),
            //       labelPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: -2.0),
            //     ),
            //   ],
            //   )
            // ],
            // ),
          ),
          new PopupMenuButton(
            icon: new Icon(Icons.more_horiz),
            itemBuilder: (BuildContext context) {
              return [PopupMenuItem(value: 'remove', child: new Text('Remove'))];
            },
            onSelected: (dynamic item) {
              switch (item as String) {
                case 'remove':
                  TodoStateChangeNotification(
                      id: widget.todo.id,
                      stateChange: 'remove',
                      data: {'todo': widget.todo, 'index': widget.index}).dispatch(context);
                  break;
              }
            },
          )
        ],
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
                if (result) TodoStateChangeNotification(stateChange: 'wipe').dispatch(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
