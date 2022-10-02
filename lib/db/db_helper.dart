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
      await db
          .execute("CREATE TABLE $TableName(date TEXT, time TEXT ,loc TEXT)");
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  //Create
  createData(Data data) async {
    final db = await database;
    var res = await db.rawInsert(
        'INSERT INTO $TableName(date,time,loc) VALUES(?,?,?)',
        [data.date, data.time, data.loc]);
    return res;
  }

  //Read
  getData(String date, String time) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM $TableName WHERE date = ? and time =?', [date, time]);
    return List.generate(maps.length, (index) {
      return Data(
          date: maps[index]['date'] as String,
          time: maps[index]['time'] as String,
          loc: maps[index]['loc'] as String);
    });
  }

  //Read All for use
  Future<Map<DateTime, dynamic>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$TableName');
    Map<DateTime, dynamic> c = Map();
    for (var i in maps) {
      DateTime a = DateTime.parse(i['date'] + ' 00:00:00.000Z');
      List b;
      // 하루에 여러개 이벤트있을경우
      if (c[a] == null) {
        b = [i['time'] + ' ' + i['loc']];
      } else {
        b = c[a] + [i['time'] + ' ' + i['loc']];
      }
      c[a] = b;
    }
    return c;
  }

  //Read All
  Future<List<Data>> getAllDatas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('$TableName');
    List<Data> list = List.generate(maps.length, (index) {
      return Data(
          date: maps[index]['date'] as String,
          time: maps[index]['time'] as String,
          loc: maps[index]['loc'] as String);
    });
    return list;
  }

  //Delete
  deleteData(String date, String time) async {
    final db = await database;
    var res = db.rawDelete(
        'DELETE FROM $TableName WHERE date = ? and time = ?', [date, time]);
    return res;
  }

  //Delete All
  deleteAllDatas() async {
    final db = await database;
    db.rawDelete('DELETE FROM $TableName');
  }
}
