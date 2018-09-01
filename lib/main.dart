import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'filerw.dart';
import 'dart:math';
import './style.dart';

void main() {
  enableFlutterDriverExtension();

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
      if (toScroll < offset &&
          widget.homeScrlCtrl.position.maxScrollExtent - offset >= 120.0) {
        widget.homeScrlCtrl.animateTo(
          toScroll,
          duration: new Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
        debugPrint('Hiding Scroll fired @$offset');
        setState(() {
          foundEasterEgg = false;
        });
        return true;
      } else if (widget.homeScrlCtrl.position.maxScrollExtent - offset <
              120.0 &&
          widget.homeScrlCtrl.position.maxScrollExtent - offset > 0) {
        widget.homeScrlCtrl.animateTo(
          widget.homeScrlCtrl.position.maxScrollExtent,
          duration: new Duration(milliseconds: 150),
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
              delegate:
                  new SliverChildBuilderDelegate((BuildContext ctx, int index) {
                if (index < 10)
                  return new TodoCard(
                    title: "Card $index",
                  );
                else
                  return null;
              }, childCount: 10),
            ),
            new SliverFillRemaining(
              child: new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.0),
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
                      color: new Color(0xff0000ff),
                      fontWeight: FontWeight.w300,
                      fontSize: 24.0),
                )),
                new IconButton(
                  icon: new Icon(Icons.expand_less),
                  onPressed: null,
                ),
              ],
            ),
          ),
          new Column(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
  @override
  State<StatefulWidget> createState() {
    new _TodoListItemState();
  }
}

class _TodoListItemState extends State<TodoListItem> {
  @override
  Widget build(BuildContext context) {
    return new InkWell(
      child: new Row(),
    );
  }
}
