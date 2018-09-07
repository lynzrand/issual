import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import './filerw.dart';

import './style.dart';
import './search_screen.dart';
import './todo_view.dart';
import './notifications.dart';
import './todo_widgets.dart';

bool isDarkTheme = false;

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
      // theme: IssualColors.issualMainTheme,
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

  // bool foundEasterEgg = false;
  Filerw _rw;
  bool _rwInitialized = false;
  Map<String, List<Todo>> displayedTodos = {};
  List<TodoCategory> categories = [];

  // bool isDarkTheme = false;

  /// Handles ALL notifications bubbling up the app.
  /// TODO: Intercept some notifications midway if needed.
  bool _notificationHandler(Notification t) {
    debugPrint(t.toString());

    if (t is TodoStateChangeNotification) {
      todoStateChangeHandler(t);
      return true;
    } else if (t is TodoEditNotification) {
      todoEditHandler(t);
      return true;
    } else if (t is TodoCategoryChangeNotification) {
      switch (t.type) {
        case TodoCategoryChangeType.add:
          showDialog<TodoCategory>(
            context: context,
            builder: (context) {
              return new IssualNewCategoryDialog();
            },
          ).then((result) async {
            debugPrint('result');
            if (result != null) {
              try {
                await _rw.addCategory(result);
                await this.init(null);
              } catch (e) {
                debugPrint(e);
              }
            }
          });
          break;
        case TodoCategoryChangeType.remove:
          _rw.removeCategory(t.data).then(this.init);
          break;
        default:
          debugPrint('Method for ${t.type} not implemented yet.');
          break;
      }
      return true;
    } else if (t is DebugSwitchNightModeNotificaton) {
      setState(() {
        isDarkTheme = !isDarkTheme;
      });
    }
  }

  void todoStateChangeHandler(TodoStateChangeNotification t) {
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
          displayedTodos[(t.data['todo'] as Todo).category.name].removeAt(t.data['index']);
        });
        _rw.removeTodo(id: t.id);
        break;

      /// WIPE: DANGEROUS Wipe out the whole database
      case TodoStateChangeType.wipe:
        _rw.init(deleteCurrentDatabase: true).then(this.init);
        break;
      default:
        break;
    }
  }

  void todoEditHandler(TodoEditNotification t) {
    Navigator.push(
      context,
      IssualTransitions.verticlaPageTransition(
        (BuildContext context, ani1, ani2) =>
            new IssualTodoEditorView(t.newTodo, t.rawTodo, t.category, _rw),
      ),
    ).then((dynamic data) async {
      await this.init(null);
    }).catchError((e) => debugPrint(e));
  }

  Widget _buildTodoCard(BuildContext ctx, int index) {
    if (!this._rwInitialized)
      return null;
    else
      return new TodoCard(
        category: categories[index],
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
      child: new AnimatedTheme(
        data: isDarkTheme ? IssualColors.issualMainThemeDark : IssualColors.issualMainTheme,
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
          // floatingActionButton: new IssualFAB(),
        ),
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
      expandedHeight: 240.0,
      title: new Text(
        'iL/all_todos',
      ),
      flexibleSpace: new FlexibleSpaceBar(
        background: Container(
          // TODO: show real data!
          alignment: Alignment.center,
          // child: Text('=v='),
        ),
      ),
      actions: <Widget>[
        // TODO: add settings
        // new IconButton(
        //   icon: Icon(Icons.brightness_3),
        //   onPressed: () {
        //     DebugSwitchNightModeNotificaton().dispatch(context);
        //   },
        // ),
        // new IconButton(
        //   icon: Icon(Icons.search),
        //   onPressed: () {
        //     Navigator.push(context, MaterialPageRoute(builder: (context) => IssualSearchScreen()));
        //   },
        // )
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

class IssualNewCategoryDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualNewCategoryDialogState();
  }
}

class _IssualNewCategoryDialogState extends State<IssualNewCategoryDialog> {
  // String text;
  String color = 'blue';
  var controller = new TextEditingController();

  void validateAndPop() {
    Navigator.pop(context, TodoCategory(name: controller.text, color: color));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Dialog(
      child: new SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Container(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: new Text(
                'Create new category',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            new Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(hintText: 'Category name'),
                textCapitalization: TextCapitalization.words,
                autovalidate: true,
                validator: (text) => text == "" ? 'Category name must not be empty' : null,
              ),
            ),
            new Container(
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Text(
                'Theme Color:',
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
            new NotificationListener(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: new GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                  ),
                  itemBuilder: (context, index) {
                    return IssualNewCategoryColorSelector(
                      index,
                      IssualColors.coloredThemes.keys.elementAt(index) == color,
                    );
                  },
                  shrinkWrap: true,
                  itemCount: IssualColors.coloredThemes.keys.length,
                ),
                constraints: BoxConstraints(maxHeight: 480.0),
              ),
              onNotification: (t) {
                if (t is CategoryColorSelectorNotification)
                  setState(() {
                    color = t.key;
                  });
              },
            ),
            new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: Text('OK'),
                  onPressed: validateAndPop,
                ),
                new FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}

class IssualNewCategoryColorSelector extends StatelessWidget {
  IssualNewCategoryColorSelector(this.index, this.state);
  final index;
  final state;
  String _key() {
    return IssualColors.coloredThemes.keys.elementAt(index);
  }

  Widget getChildOnState() {
    if (state) {
      return IgnorePointer(
        child: Container(
          alignment: Alignment.center,
          child: Icon(
            Icons.done,
            color: Colors.white,
          ),
        ),
      );
    } else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return new GridTile(
      child: Container(
        child: Material(
          color: IssualColors.coloredThemes[_key()]['primarySwatch'] as MaterialColor,
          child: InkWell(
            onTap: () => CategoryColorSelectorNotification(_key()).dispatch(context),
            child: AnimatedSwitcher(
              child: getChildOnState(),
              duration: Duration(microseconds: 100),
            ),
          ),
          // shape:,
        ),
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
