//these top three are very important

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_list/model/todoitem.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableName = "todoTbl";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,
        "todo_db.db"); // home://directory/files/todo_db.db
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  // to create a table like
  //     id | username | password
  //----------------------------------
  //      1 |  abass   | wgjgjgj
  // and so on

  // CRUD- create Read Update Delete
  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDateCreated TEXT)");
  }

  //insertion
  Future<int> saveItem(TodoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    return res;
  }

  //get user
  Future<List> getAllItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnItemName ASC");
    return result.toList();
  }

  //get count
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  //get single item
  Future<TodoItem> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $tableName WHERE $columnId = $id");
    if (result.length == 0) {
      return null;
    } else {
      return TodoItem.fromMap(result.first);
    }
  }

  //delete
  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  // update
  Future<int> updateItem(TodoItem item) async {
    var dbClient = await db;
    return await dbClient.update(tableName, item.toMap(),
        where: "$columnId = ?", whereArgs: [item.id]);
  }

  // close
  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }


}
