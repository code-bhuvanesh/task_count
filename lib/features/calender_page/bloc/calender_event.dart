part of 'calender_bloc.dart';

@immutable
sealed class CalenderEvent {}

class GetCurrentDate extends CalenderEvent {}

class GetAllDates extends CalenderEvent {
  final String taskname;
  final int month;
  final int year;
  GetAllDates({
    required this.taskname,
    required this.month,
    required this.year,
  });
}

class AddCheckMark extends CalenderEvent {
  final CustomDate date;
  final String taskname;
  AddCheckMark({
    required this.date,
    required this.taskname,
  });
}

class RemoveCheckMark extends CalenderEvent {
  final CustomDate date;
  final String taskname;
  RemoveCheckMark({
    required this.date,
    required this.taskname,
  });
}

class GetTasksList extends CalenderEvent {}

class AddNewTask extends CalenderEvent {
  final String taskName;

  AddNewTask({required this.taskName});
}

class UpdateTaskName extends CalenderEvent {
  final String oldTaskName;
  final String newTaskName;

  UpdateTaskName({
    required this.oldTaskName,
    required this.newTaskName,
  });
}

class AddNote extends CalenderEvent {
  final String taskName;
  final DateTime date;
  final String note;

  AddNote({
    required this.taskName,
    required this.date,
    required this.note,
  });
}

class GetNote extends CalenderEvent {
  final String taskName;
  final DateTime date;

  GetNote({
    required this.taskName,
    required this.date,
  });
}
