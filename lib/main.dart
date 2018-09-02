import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'filerw.dart';
import 'dart:math';
import './style.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
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
  ScrollController homeScrlCtrl = new ScrollController();

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool foundEasterEgg = false;

  bool _notificationHandler(Notification t) {
    // debugPrint(t.toString());
    if (t is UserScrollNotification) {
      double toScroll = widget.homeScrlCtrl.position.maxScrollExtent -
          widget.homeScrlCtrl.position.viewportDimension +
          48;
      double offset = widget.homeScrlCtrl.offset;
      // debugPrint('Notification at $offset; To match: $toScroll');
      /* 
       * FIXME: The following assertion was thrown while handling a gesture:
       * 'package:flutter/src/widgets/scrollable.dart': Failed assertion: 
       * line 445 pos 12: '_hold == null': is not true.
       * 
       * TODO: replace this with ScrollPhysics if possible!
       * Note: This bug DOES NOT affect release versions of the app.
       * 
       * An issue has already been posted on Github at 
       * https://github.com/flutter/flutter/issues/14452. 
       * No official fixes has been released though.
       * USE WITH CAUTION!
       */
      if (toScroll < offset && widget.homeScrlCtrl.position.maxScrollExtent - offset >= 120.0) {
        widget.homeScrlCtrl.animateTo(
          toScroll,
          duration: new Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
        debugPrint('Hiding Scroll fired @$offset');
        setState(() {
          foundEasterEgg = false;
        });
        return true;
      } else if (widget.homeScrlCtrl.position.maxScrollExtent - offset < 120.0 &&
          widget.homeScrlCtrl.position.maxScrollExtent - offset > 0) {
        widget.homeScrlCtrl.animateTo(
          widget.homeScrlCtrl.position.maxScrollExtent,
          duration: new Duration(milliseconds: 50),
          curve: Curves.easeOut,
        );
        setState(() {
          foundEasterEgg = true;
        });
      } else if (widget.homeScrlCtrl.position.maxScrollExtent - offset == 0) {
        setState(() {
          foundEasterEgg = true;
        });
      } else {
        setState(() {
          foundEasterEgg = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: new AppBar(
      //   title: new Text(widget.title),
      // ),
      body: new NotificationListener(
        onNotification: _notificationHandler,
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              pinned: true,
              expandedHeight: 360.0,
              flexibleSpace: new FlexibleSpaceBar(
                background: Container(
                  // TODO: show real data!
                  child: new Text("data"),
                  alignment: Alignment.center,
                ),
                title: new Text('issual/Todos'),
              ),
              actions: <Widget>[
                new IconButton(
                  icon: Icon(Icons.eject),
                  onPressed: () {},
                )
              ],
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate((BuildContext ctx, int index) {
                // TODO: show REAL todos!
                if (index < 10)
                  return new TodoCard(
                    title: "Card $index",
                  );
                else
                  return null;
              }, childCount: 2),
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
      ),
      backgroundColor: Colors.blueGrey.shade500,
      drawer: new Drawer(
        child: new Text(
          "data",
        ),
      ),
    );
  }
}

class TodoCard extends StatefulWidget {
  TodoCard({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _TodoCardState();

  final String title;
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
            children: [
              new TodoListItem(new Todo(rawTodo: {'title': 'Test'}))
            ],
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
  final stateIcons = <String, IconData>{
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
      child: new InkWell(
        splashColor: IssualColors.darkColorRipple,
        onTap: () => {},
        child: new Row(
          children: <Widget>[
            new IconButton(
              // FIXME: Icon does not show up
              icon: new Icon(widget.stateIcons[state.toString() ?? 'closed']),
              onPressed: () => {},
            ),
            new Expanded(child: Text(this.widget.todo.title)),
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
