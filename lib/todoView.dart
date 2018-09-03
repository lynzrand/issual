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
            child: new Text(this.title),
            tag: widget.id + 'title',
          ),
        ],
      ),
    );
  }
}

class IssualTodoEditorView extends StatefulWidget {
  IssualTodoEditorView(this.isNew, this.rawTodo);
  final bool isNew;
  final Map<String, dynamic> rawTodo;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualTodoEditorViewState(rawTodo);
  }
}

class _IssualTodoEditorViewState extends State<IssualTodoEditorView> {
  _IssualTodoEditorViewState(this.rawTodo);
  Map<String, dynamic> rawTodo;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new CustomScrollView(
        slivers: <Widget>[new SliverToBoxAdapter(child: new TextField())],
      ),
    );
  }
}
