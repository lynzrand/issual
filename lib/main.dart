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
      theme: new ThemeData(
        primarySwatch: IssualColors.primary,
      ),
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
  void init(_) {
    _rw.getRecentTodos().then((Map<String, List<Todo>> todosGot) {
      setState(() {
        this._rwInitialized = true;
        this.displayedTodos = todosGot;
      });
    }, onError: (e) {
      debugPrint(e.toString());
    });
  }

  bool foundEasterEgg = false;
  Filerw _rw;
  bool _rwInitialized = false;
  Map<String, List<Todo>> displayedTodos = {};

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
    // } else
    if (t is TodoStateChangeNotification) {
      switch (t.stateChange) {

        /// FLIP: flip Todo's state
        /// e.g.
        ///   open, active, pending => closed
        ///   closed, canceled => open
        case 'flip':
          // TODO: implement FLIP
          break;

        /// ADD: add Todo in t.data to database
        case 'add':
          this.setState(() {
            this.displayedTodos[t.data.category] ??= [];
            this.displayedTodos[t.data.category].add(t.data as Todo);
          });
          _rw.postTodo(todo: t.data as Todo);
          break;

        /// VIEW: navigate to Todo whose id == t.id
        case 'view':
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return new IssualTodoView(t.id, t.data as String, _rw);
          }));
          break;
      }
      return true;
    }
  }

  Widget _buildTodoCard(BuildContext ctx, int index) {
    // TODO: show categorized todo cards
    return new TodoCard(
      title: displayedTodos.keys.elementAt(index),
      todos: displayedTodos[displayedTodos.keys.elementAt(index)],
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
            new SliverToBoxAdapter(
              child: new Container(
                child: new Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: new Column(
                    children: <Widget>[
                      new ListTile(
                        title: Text('Database Loaded: $_rwInitialized'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(this._buildTodoCard,
                  childCount: displayedTodos.keys.length),
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
        backgroundColor: Colors.blueGrey.shade500,
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
        title: new Text('issual/all_todos'),
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

class TodoCard extends StatefulWidget {
  TodoCard({Key key, this.title, this.todos}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _TodoCardState();

  final String title;
  final List<Todo> todos;
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.fromLTRB(24.0, 0.0, 0.0, 0.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                  '${widget.title}',
                  style: new TextStyle(
                      color: new Color(0xff0000ff), fontWeight: FontWeight.w300, fontSize: 24.0),
                )),
                new IconButton(
                  icon: new Icon(Icons.expand_less),
                  onPressed: null,
                ),
              ],
            ),
          ),
          new Column(
            children: List.generate(widget.todos.length, (int index) {
              return new TodoListItem(widget.todos[index]);
            }),
          ),
          new ButtonBar(
            children: <Widget>[
              // new IconButton(
              //   icon: new Icon(Icons.add),
              //   onPressed: null,
              // )
              new FlatButton(
                child: new Text("Add".toUpperCase()),
                onPressed: () => {},
              )
            ],
          ),
        ],
      ),
    );
  }
}

class TodoListItem extends StatefulWidget {
  TodoListItem(final this.todo);

  // TODO: move this to filerw.dart/todo
  static const stateIcons = <String, IconData>{
    'open': Icons.error_outline,
    'closed': Icons.check_circle_outline,
    'pending': Icons.access_time,
    'active': Icons.data_usage,
    'disabled': Icons.remove_circle_outline,
  };
  final Todo todo;

  @override
  State<StatefulWidget> createState() {
    return new _TodoListItemState();
  }
}

class _TodoListItemState extends State<TodoListItem> {
  // TodoState state;
  String state;

  @override
  Widget build(BuildContext context) {
    return new Dismissible(
      key: Key(widget.todo.id),
      onDismissed: (DismissDirection dir) {
        TodoStateChangeNotification(id: widget.todo.id, stateChange: 'flip').dispatch(context);
      },
      child: new InkWell(
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
              icon: new Icon(TodoListItem.stateIcons[state ?? 'closed']),
              onPressed: () => {},
            ),
            new Expanded(
              child:
                  // TODO: Really, show tags?
                  //
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  new Hero(
                tag: this.widget.todo.id + 'title',
                child: new Text(this.widget.todo.title),
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
            new IconButton(
              icon: new Icon(Icons.more_horiz),
              onPressed: () => {},
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
        Scaffold.of(context).showSnackBar(
          SnackBar(
            // content: new Text('Filerw.AddTodo() not implemented'),
            content: new Text('Adding a sample Todo to database'),
          ),
        );
        TodoStateChangeNotification(
            id: null,
            stateChange: 'add',
            data: new Todo(
              isNewTodo: true,
              rawTodo: {
                'title': 'Test Todo',
                'desc': 'DESC',
                'category': ['todo', 'otherCategory', 'otherCategory2'][Random().nextInt(3)]
              },
            )).dispatch(context);
      },
    );
  }
}
