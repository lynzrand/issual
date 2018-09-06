import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import './filerw.dart';

import './style.dart';
import './search_screen.dart';
import './todo_view.dart';
import './notifications.dart';
import './todo_widgets.dart';

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
      _rw.getCategories().then((List<TodoCategory> categories) {
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
  List<TodoCategory> categories = [];

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
    } else if (t is TodoCategoryChangeNotification) {
      switch (t.type) {
        case TodoCategoryChangeType.add:

        default:
          debugPrint('Method for ${t.type} not implemented yet.');
          break;
      }
    }
  }

  Widget _buildTodoCard(BuildContext ctx, int index) {
    if (!this._rwInitialized)
      return null;
    else
      return new TodoCard(
        title: categories[index].name,
        todos: displayedTodos[categories[index].name],
        themeColors: IssualColors.coloredThemes[categories[index].color] ??
            IssualColors.coloredThemes['blue'],
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

class IssualFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
      child: new Icon(Icons.add),
      onPressed: () {
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
              title: Text(
                'You are running a public beta version of iL!',
                style: Theme.of(context).textTheme.body2,
              ),
            ),
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
