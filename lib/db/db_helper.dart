import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dalo/db/db_model.dart';

final String TableName = 'Data';

class DBHeler {
  DBHeler._();
  static final DBHeler _db = DBHeler._();
  factory DBHeler() => _db;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'MyData.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE $TableName(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT, time TEXT ,loc TEXT)");
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  //Create
  createData(Data data) async {
    final db = await database;
    var res = await db.rawInsert(
        'INSERT INTO $TableName(id,date,time,loc) VALUES(?,?,?,?)',
        [data.id, data.date, data.time, data.loc]);
    return res;
  }

  //Read
  getData(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM $TableName WHERE id = ?', [id]);
    return List.generate(maps.length, (index) {
      return Data(
          id: maps[index]['id'] as int,
          date: maps[index]['date'] as String,
          time: maps[index]['time'] as String,
          loc: maps[index]['loc'] as String);
    });
  }

  Future<Map<DateTime, dynamic>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$TableName');
    Map<DateTime, dynamic> c = Map();
    for (var i in maps) {
      DateTime a = DateTime.parse(i['date'] + ' 00:00:00.000Z');
      List b = [i['time'] + ' ' + i['loc']];
      c[a] = b;
      // print(c);
    }
    return c;
  }

  //Read All
  Future<List<Data>> getAllDatas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$TableName');
    List<Data> list = List.generate(maps.length, (index) {
      return Data(
          id: maps[index]['id'] as int,
          date: maps[index]['date'] as String,
          time: maps[index]['time'] as String,
          loc: maps[index]['loc'] as String);
    });
    return list;
  }

  //Delete
  deleteData(int id) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName WHERE id = ?', [id]);
    return res;
  }

  //Delete All
  deleteAllDatas() async {
    final db = await database;
    db.rawDelete('DELETE FROM $TableName');
  }
}
