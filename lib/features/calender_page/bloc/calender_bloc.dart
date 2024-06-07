import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_count/data/models/custom_date.dart';
import 'package:task_count/data/models/task.dart';
import 'package:task_count/utils/helpers.dart';
import 'package:flutter/services.dart';

import '../../../data/repository/task_repo.dart';

part 'calender_event.dart';
part 'calender_state.dart';

class CalenderBloc extends Bloc<CalenderEvent, CalenderState> {
  CalenderBloc() : super(CalenderInitial()) {
    on<GetCurrentDate>(onGetCurrentDate);
    on<GetAllDates>(onGetAllDates);
    on<AddCheckMark>(onAddCheckMark);
    on<RemoveCheckMark>(onRemoveCheckMark);
    on<GetTasksList>(onGetTaskList);
    on<AddNewTask>(onAddNewTask);
    on<UpdateTaskName>(onUpdateTaskName);
    on<AddNote>(onAddNotes);
    on<GetNote>(onGetNote);
  }

  FutureOr<void> onGetCurrentDate(
    GetCurrentDate event,
    Emitter<CalenderState> emit,
  ) async {
    var now = DateTime.now();
    var currenDate = DateTime(now.year, now.year);
    emit(CurrentDate(date: currenDate));
  }

  FutureOr<void> onGetAllDates(
    GetAllDates event,
    Emitter<CalenderState> emit,
  ) async {
    Map<CustomDate, bool> allDates = {};
    dateGenrator(event.month, event.year).forEach(
      (e) => allDates.addAll(
        {e: false},
      ),
    );
    var data = await TaskRepo.querryMonth(
      event.taskname,
      month: event.month,
      year: event.year,
    );
    data.forEach((element) {
      allDates[element.date] = element.isChecked;
    });
    emit(AllDates(dates: allDates));
  }

  FutureOr<void> onAddCheckMark(
    AddCheckMark event,
    Emitter<CalenderState> emit,
  ) async {
    await TaskRepo.addCheck(
      event.taskname,
      event.date.date!,
    );

    emit(CheckMarkAdded(date: event.date));
  }

  FutureOr<void> onRemoveCheckMark(
    RemoveCheckMark event,
    Emitter<CalenderState> emit,
  ) async {
    await TaskRepo.removeCheck(
      event.taskname,
      event.date.date!,
    );
    emit(CheckMarkRemoved(date: event.date));
  }

  FutureOr<void> onGetTaskList(
    GetTasksList event,
    Emitter<CalenderState> emit,
  ) async {
    var tasksList = await TaskRepo.getAllTasks();
    emit(TasksList(tasklist: tasksList));
  }

  FutureOr<void> onAddNewTask(
    AddNewTask event,
    Emitter<CalenderState> emit,
  ) async {
    var tasksList = await TaskRepo.getAllTasks();
    if (tasksList.contains(event.taskName)) {
      emit(TaskExists(taskname: event.taskName));
    } else {
      await TaskRepo.createNewTasks(event.taskName);
      emit(NewTaskAdded(newTask: event.taskName));
      //add(GetTasksList());
    }
  }

  FutureOr<void> onUpdateTaskName(
    UpdateTaskName event,
    Emitter<CalenderState> emit,
  ) async {
    TaskRepo.updateTaskName(
      event.oldTaskName,
      event.newTaskName,
    );
    emit(TaskNameUpdated(newtaskname: event.newTaskName));
    //add(GetTasksList());
  }

  FutureOr<void> onAddNotes(
    AddNote event,
    Emitter<CalenderState> emit,
  ) async {
    await TaskRepo.addNotes(event.taskName, event.date, event.note);
    emit(NoteAdded());
  }

  FutureOr<void> onGetNote(
    GetNote event,
    Emitter<CalenderState> emit,
  ) async {
    var task = await TaskRepo.querry(event.taskName, event.date);
    print("note task : $task");
    emit(NoteState(task: task, date: event.date));
  }
}
