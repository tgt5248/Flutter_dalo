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
    var res = await db.rawQuery('SELECT * FROM $TableName WHERE id = ?', [id]);
    return res.isNotEmpty
        ? Data(
            id: res.first['id'] as int,
            date: res.first['date'] as String,
            time: res.first['time'] as String,
            loc: res.first['loc'] as String)
        : Null;
  }

  //Read All
  Future<List<Data>> getAllDatas() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $TableName');
    List<Data> list = res.isNotEmpty
        ? res
            .map((c) => Data(
                id: res.first['id'] as int,
                date: c['date'] as String,
                time: c['time'] as String,
                loc: c['loc'] as String))
            .toList()
        : [];

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
