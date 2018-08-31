import 'package:flutter/material.dart';
import './style.dart';

void main() => runApp(new MyApp());

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

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(
          children: <Widget>[
            new TodoCard(
              title: "Todos",
            )
          ],
        ),
        drawer: new Drawer(child: new Text("data")));
  }
}

class TodoCard extends StatefulWidget {
  TodoCard({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _TodoCardState();

  String title;
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.all(16.0),
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
          //,
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
