part of 'calender_bloc.dart';

@immutable
sealed class CalenderState {}

final class CalenderInitial extends CalenderState {}

class CurrentDate extends CalenderState {
  final DateTime date;

  CurrentDate({required this.date});
}

class AllDates extends CalenderState {
  final Map<CustomDate, bool> dates;
  AllDates({required this.dates});
}

class CheckMarkAdded extends CalenderState {
  final CustomDate date;

  CheckMarkAdded({required this.date});
}

class CheckMarkRemoved extends CalenderState {
  final CustomDate date;

  CheckMarkRemoved({required this.date});
}

class TasksList extends CalenderState {
  final List<String> tasklist;

  TasksList({required this.tasklist});
}

class NewTaskAdded extends CalenderState {
  final String newTask;

  NewTaskAdded({required this.newTask});
}

class TaskNameUpdated extends CalenderState {
  final String newtaskname;

  TaskNameUpdated({required this.newtaskname});

}

class TaskExists extends CalenderState {
  final String taskname;

  TaskExists({required this.taskname});

}
