import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:task_count/data/models/custom_date.dart';

import '../../utils/helpers.dart';

class TaskRepo {
  static Database? db;
  static const String _alltasks = "alltasks";
  static const String _allnotes = "allnotes";
  static Future<Database> open() async {
    if (db != null) return db!;
    var path = "${await getDatabasesPath()}taskslist4.db";
    print("db path = $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) {
        //create tables for tasks
        db.execute(
          "CREATE TABLE $_alltasks (id INTEGER PRIMARY KEY AUTOINCREMENT, taskname TEXT UNIQUE, tablename TEXT UNIQUE);",
        );
        db.execute(
          "CREATE TABLE task1 (id INTEGER PRIMARY KEY AUTOINCREMENT, date DATE UNIQUE, isChecked BOOLEAN, note Text);",
        );
        db.insert(_alltasks, {"taskname": "task1", "tablename": "task1"});
      },
    );
  }

  static Future<String> getTableName(String taskName) async {
    var db = await open();
    var tableName = (await db.query(_alltasks,
        columns: ["tablename"],
        where: "taskname = ?",
        whereArgs: [taskName]))[0]["tablename"] as String;
    return tableName;
  }

  static Future<List<String>?> createNewTasks(String taskname) async {
    var db = await open();
    var data = await getAllTasks();
    if (data.contains(taskname)) return null;
    data.add(taskname);
    db.insert(
        _alltasks, {"taskname": taskname, "tablename": "task${data.length}"});
    db.execute(
      "CREATE TABLE task${data.length} (id INTEGER PRIMARY KEY AUTOINCREMENT, date DATE UNIQUE, isChecked BOOLEAN, note Text);",
    );
    return data;
  }

  static Future<String> updateTaskName(
    String oldTaskName,
    String newTaskName,
  ) async {
    var db = await open();
    if (oldTaskName != newTaskName) {
      await db.update(
        _alltasks,
        {
          "taskname": newTaskName,
        },
        where: "taskname = ?",
        whereArgs: [oldTaskName],
      );
    }
    print(await getAllTasks());
    return newTaskName;
  }

  static Future<List<String>> getAllTasks() async {
    var db = await open();
    var data = (await db.query(_alltasks))
        .map((e) => (e["taskname"] as String).replaceAll("_", " "))
        .toList();

    return data;
  }

  static String _dateToString(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  static DateTime _stringToDate(String date) {
    return DateTime.parse(date);
  }

  static Future addCheck(String taskName, DateTime date) async {
    // if (_db == null) throw ("database not initiated call open method first");
    var db = await open();
    try {
      var tableName = await getTableName(taskName);
      await db.insert(
        tableName,
        {
          "date": _dateToString(date),
          "isChecked": 1,
        },
      );
    } on Exception catch (_) {
      print("cannot insert same date");
    }

    await querryAll(taskName, db: db);
  }

  static Future removeCheck(String taskName, DateTime date,
      {Database? db}) async {
    db ??= await open();
    var tableName = await getTableName(taskName);
    var i = await db.update(
      tableName,
      {"isChecked": 0},
      where: "date = ?",
      whereArgs: [_dateToString(date)],
    );
    print("no of rows affected: $i");
    await querryAll(taskName, db: db);
  }

  static Future addNotes(String taskName, DateTime date, String note) async {
    // if (_db == null) throw ("database not initiated call open method first");
    var db = await open();
    try {
      var tableName = await getTableName(taskName);
      if (await querry(taskName, date) == null) {
        await db.insert(
          tableName,
          {
            "date": _dateToString(date),
            "isChecked": 1,
            "note" : "",
          },
        );
      }
      else{
         await db.update(
        _alltasks,
        {
          "note": note,
        },
        where: "date LIKE ?",
        whereArgs: ['${ formatDate(date)}%'],
      );
      }
    } on Exception catch (_) {
      print("cannot insert same date");
    }

    await querryAll(taskName, db: db);
  }

  static Future<Map<String, dynamic>?> querry(
      String taskName, DateTime date) async {
    db = await open();
 
    var formatted = formatDate(date);
    var tableName = await getTableName(taskName);
    var data = await db!.rawQuery(
      "Select * from $tableName where date LIKE ?",
      ['$formatted%'],
    );
    print("Database : \n $data");

    return data.isNotEmpty ? data[0] : null;
  }

  static Future<Map<CustomDate, bool>> querryAll(
    String taskName, {
    int? month,
    int? year,
    Database? db,
  }) async {
    db ??= await open();
    var formattedDate = "";
    if (month != null) {
      String formattedMonth = month < 10 ? '0$month' : '$month';
      formattedDate = '$year-$formattedMonth';
    }
    var tableName = await getTableName(taskName);
    Map<CustomDate, bool> dates = {};
    var data = await db.rawQuery(
        "Select * from $tableName where date LIKE ?", ['$formattedDate%']);
    print("Database : \n $data");
    data.forEach((e) {
      var d = _stringToDate(e["date"] as String);
      dates.addAll({CustomDate(date: d): (e["isChecked"] == 1)});
    });

    return dates;
  }
}
