import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_count/features/statistics_page/graph_widget.dart';
import 'package:task_count/utils/constants.dart';

import '../calender_page/bloc/calender_bloc.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  var taskList = ["task1"];
  var taskNumber = 0;
  var taskLength = 0;

  var taskCount = 0;
  var currentMonth = 1;
  var currentYear = 2024;

  var datesDetails = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: SafeArea(
          child: BlocListener<CalenderBloc, CalenderState>(
            listener: (context, state) async {
              if (state is TasksList) {
                setState(() {
                  taskList = state.tasklist;
                });
                context.read<CalenderBloc>().add(
                      GetAllDates(
                        taskname: taskList[taskNumber],
                        month: currentMonth,
                        year: currentYear,
                      ),
                    );
              }
              if (state is AllDates) {
                setState(() {
                  datesDetails = state.dates;
                  taskCount = 0;
                  datesDetails.forEach((key, value) {
                    if (value) taskCount++;
                  });
                });
              } else if (state is CheckMarkAdded) {
                setState(() {
                  datesDetails.addAll({state.date: true});
                  taskCount++;
                });
              } else if (state is CheckMarkRemoved) {
                setState(() {
                  datesDetails.addAll({state.date: false});
                  taskCount--;
                });
              } else if (state is NoteState) {
                var oldNote = state.task == null ? "" : state.task!.note;
                var notesController = TextEditingController(
                  text: oldNote,
                );

                print("notes : ${notesController.text}");
                if (mounted && notesController.text != oldNote) {
                  context.read<CalenderBloc>().add(
                        AddNote(
                          taskName: taskList[taskNumber],
                          date: state.date,
                          note: notesController.text,
                        ),
                      );
                }
              }
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customIconButton(Icons.arrow_left, next: false),
                    GestureDetector(
                      // onTap: () async {
                      //   await bottomSheet(
                      //     childBuilder: (controller, height) =>
                      //         BlocProvider(
                      //       create: (context) => CalenderBloc(),
                      //       child: AddTaskSheet(
                      //         scrollController: controller,
                      //         sheetHeight: height,
                      //         topPadding:
                      //             MediaQuery.of(context).padding.top,
                      //       ),
                      //     ),
                      //   );
                      //   if (mounted) {
                      //     context.read<CalenderBloc>().add(
                      //           GetTasksList(),
                      //         );
                      //   }
                      // },
                      child: Text(
                        taskList[taskNumber],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    customIconButton(Icons.arrow_right, next: true),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: GraphWidget(
                      topValue: 8,
                      plots: [3, 2, 5, 6, 8],
                      horizontalValues: ["jan", "feb", "mar", "apr", "may"],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customIconButton(IconData icon, {required bool next}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20,
          )),
      margin: const EdgeInsets.all(10),
      child: IconButton(
        onPressed: () {
          setState(() {
            if (next) {
              if (taskNumber < taskList.length - 1) {
                taskNumber++;
              }
            } else {
              if (taskNumber > 0) {
                taskNumber--;
              }
            }
            context.read<CalenderBloc>().add(
                  GetAllDates(
                    taskname: taskList[taskNumber],
                    month: currentMonth,
                    year: currentYear,
                  ),
                );
          });
        },
        icon: Icon(
          icon,
          size: 40,
          color: const Color.fromARGB(255, 70, 70, 70),
        ),
      ),
    );
  }
}
