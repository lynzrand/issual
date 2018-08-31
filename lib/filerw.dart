import 'package:sqflite/sqflite.dart';

class Filerw {
  Filerw(){
  }
  
  init() async{
    this._path = await getDatabasesPath()
  }

  String _path;
}
