import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';
import 'filerw.dart';

class IssualSearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _IssualSearchScreenState();
  }
}

class _IssualSearchScreenState extends State<IssualSearchScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      // appBar: AppBar(title: new Text('Search')),
      body: new MaterialSearch<Todo>(
        placeholder: 'Search',
      ),
    );
  }
}
