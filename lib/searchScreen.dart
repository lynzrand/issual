import 'package:flutter/material.dart';

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
      appBar: AppBar(title: new Text('Search')),
      body: new Text("This is the Search screen.\nTODO: Implement REAL searching."),
    );
  }
}
