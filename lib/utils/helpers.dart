import 'package:sqflite/sqflite.dart';

import '../data/models/custom_date.dart';

List<CustomDate> dateGenrator(int month, int year) {
  List<CustomDate> dates = [];
  // var year = DateTime.now().year;
  var startDate = DateTime(year, month);
  var endDate = DateTime(year, month + 1);
  //.weekend starts from monday as 1 but here sunday is one
  int beforeDays = startDate.weekday == 7 ? 0 : startDate.weekday;
  List.generate(beforeDays, (index) => dates.add(CustomDate()));
  List.generate(
    endDate.difference(startDate).inDays,
    (index) => dates.add(
      CustomDate(
        date: DateTime(
          year,
          month,
          index + 1,
        ),
      ),
    ),
  );
  List.generate(
    6 * 7 - dates.length,
    (index) => dates.add(CustomDate()),
  );
  return dates;
}

Future<void> openAllTasksDb() async {
  var path = "${await getDatabasesPath()}alltasks.db";
  Database db = await openDatabase(
    path,
    onCreate: (db, _) {
      db.execute("CREATE TABLE alltasks");
    },
  );
}


String formatDate(DateTime date){
  String formattedMonth =
        date.month < 10 ? '0${date.month}' : '${date.month}';
    String formattedDate = date.day < 10 ? '0${date.day}' : '${date.day}';
    return '${date.year}-$formattedMonth-$formattedDate';
    
}