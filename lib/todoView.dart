import 'package:flutter/material.dart';
import 'dart:async';
import 'filerw.dart';

class IssualTodoView extends StatefulWidget {
  IssualTodoView(this.id, this.title, this._db);
  final String id;
  final String title;
  final Filerw _db;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoViewState(id, _db, title);
  }
}

class _IssualTodoViewState extends State<IssualTodoView> {
  _IssualTodoViewState(this.id, this._db, this.title) {
    this.init(id).then((_) => this.loaded = true);
  }
  Future<void> init(String id) async {
    this.mainTodo = await _db.getTodoById(id);
  }

  String id;
  Filerw _db;
  bool loaded = false;
  String title;
  Todo mainTodo;

  @override
  Widget build(BuildContext context) {
    // TODO: Use sliver stuff
    return new Scaffold(
      appBar: AppBar(title: new Text('#${this.id}')),
      body: Column(
        children: [
          Hero(
            child: Text(this.title),
            tag: widget.id + 'title',
          ),
        ],
      ),
    );
  }
}
