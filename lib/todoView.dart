import 'package:flutter/material.dart';
import 'filerw.dart';

class IssualTodoView extends StatefulWidget {
  IssualTodoView(this.id);
  final String id;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoViewState(id);
  }
}

class _IssualTodoViewState extends State<IssualTodoView> {
  _IssualTodoViewState(String id) {}
  init(String id) async {
    // this.mainTodo = await
  }
  Todo mainTodo;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      // appBar: AppBar(title: new Text('Search')),
      body: Column(
        children: [
          Hero(
            // child: Text(),
            tag: widget.id,
          ),
        ],
      ),
    );
  }
}
