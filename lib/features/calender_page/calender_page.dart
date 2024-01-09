import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_count/data/repository/task_repo.dart';
import 'package:task_count/features/calender_page/add_task_bottom_sheet.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_count/features/calender_page/bloc/calender_bloc.dart';

import '../../data/models/custom_date.dart';
import '../../utils/constants.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  var taskList = ["task1"];
  var taskNumber = 0;
  var taskLength = 0;

  var taskCount = 0;
  var currentMonth = 1;
  var currentYear = 2024;
  @override
  void initState() {
    context.read<CalenderBloc>().add(GetTasksList());

    var d = DateTime.now();
    setState(() {
      currentYear = d.year;
      currentMonth = d.month;
    });
    super.initState();
  }

  Map<CustomDate, bool> datesDetails = {};

  DragStartDetails? dragStartPostion;

  @override
  Widget build(BuildContext context) {
    print("MediaQuery.of(context) : ${MediaQuery.of(context).padding.top}");
    return BlocListener<CalenderBloc, CalenderState>(
      listener: (context, state) {
        setState(() {
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
            datesDetails = state.dates;
            taskCount = 0;
            datesDetails.forEach((key, value) {
              if (value) taskCount++;
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
          }
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: const Color.fromARGB(255, 230, 230, 230),
            child: Column(
              children: [
                !bottomSheetVisible
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              customIconButton(Icons.arrow_left, next: false),
                              GestureDetector(
                                onTap: () {
                                  bottomSheet(
                                    childBuilder: (controller, height) =>
                                        BlocProvider(
                                      create: (context) => CalenderBloc(),
                                      child: AddTaskSheet(
                                        scrollController: controller,
                                        sheetHeight: height,
                                        topPadding:
                                            MediaQuery.of(context).padding.top,
                                      ),
                                    ),
                                  );
                                },
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
                        ],
                      )
                    : const SizedBox.shrink(),
                GestureDetector(
                  onVerticalDragEnd: (position) {
                    setState(() {
                      if (position.velocity.pixelsPerSecond.dy < -10) {
                        currentMonth++;
                        if (currentMonth > 12) {
                          currentMonth = 1;
                          currentYear++;
                        }
                      } else if (position.velocity.pixelsPerSecond.dy > 10 &&
                          currentMonth > 0) {
                        currentMonth--;
                        if (currentMonth <= 0) {
                          currentMonth = 12;
                          currentYear--;
                        }
                      }
                    });
                    context.read<CalenderBloc>().add(
                          GetAllDates(
                            taskname: taskList[taskNumber],
                            month: currentMonth,
                            year: currentYear,
                          ),
                        );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: monthWidget(currentMonth),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool bottomSheetVisible = false;

  Future<void> bottomSheet({
    required Widget Function(
      ScrollController scrollController,
      double height,
    ) childBuilder,
  }) async {
    // setState(() {
    //   bottomSheetVisible = true;
    // });
    await showFlexibleBottomSheet(
        context: context,
        minHeight: 0,
        initHeight: 0.7,
        maxHeight: 1,
        anchors: [0, 0.7, 1],
        bottomSheetColor: const Color.fromARGB(0, 255, 255, 255),
        // isModal: true,

        barrierColor: Colors.transparent,
        // bottomSheetBorderRadius: BorderRadius.circular(50),
        builder: (bloccontext, controller, height) {
          print("d $height");
          // return BlocProvider(
          //   create: (context) => CalenderBloc(),
          //   child: AddTaskSheet(
          //     scrollController: controller,
          //     sheetHeight: height,
          //     topPadding: MediaQuery.of(context).padding.top,
          //   ),
          // );
          return childBuilder(controller, height);
        });
    if (mounted) context.read<CalenderBloc>().add(GetTasksList());
    // setState(() {
    //   bottomSheetVisible = false;
    // });
  }

  Widget dateWidget(CustomDate date) {
    double w = MediaQuery.of(context).size.width;
    // print(datesDetails[date] ?? false);
    return GestureDetector(
      onTap: () async {
        print(date);
        HapticFeedback.vibrate();

        //  bottomSheet(date);
        if (!datesDetails[date]!) {
          context.read<CalenderBloc>().add(
                AddCheckMark(
                  date: date,
                  taskname: taskList[taskNumber],
                ),
              );
        } else {
          context.read<CalenderBloc>().add(
                RemoveCheckMark(
                  date: date,
                  taskname: taskList[taskNumber],
                ),
              );
        }
      },
      onLongPress: () {
        print("long press");
        bottomSheet(
          childBuilder: (controller, height) => Container(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          child: date.day != 0
              ? Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  color: date.isCurrentDate
                      ? const Color.fromARGB(255, 155, 208, 252)
                      : Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date.day.toString(),
                        ),
                        datesDetails[date] ?? false
                            ? Icon(
                                Icons.done_rounded,
                                color: Colors.green,
                                size: w / 12,
                                fill: 1.0,
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: const Color.fromARGB(68, 158, 158, 158),
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

  Widget monthWidget(int currentMonth) {
    var height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${months[currentMonth - 1]} $currentYear",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Task count: $taskCount",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: days
                  .map(
                    (e) => Text(e.substring(0, 3).toUpperCase()),
                  )
                  .toList(),
            ),
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 7,
            crossAxisSpacing: 3,
            mainAxisSpacing: 5,
            // childAspectRatio: 0.7,
            childAspectRatio: height / 1200,
            children: datesDetails.keys
                .map(
                  (date) => dateWidget(date),
                )
                .toList(),
          ),
        ]),
        const SizedBox(
          height: 30,
        ),
        nextMonthWidget()
      ],
    );
  }

  Widget nextMonthWidget() {
    int cm = currentMonth;
    int cy = currentYear;
    if (currentMonth >= 12) {
      cm = 0;
      cy++;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          currentMonth++;
          if (currentMonth > 12) {
            currentMonth = 1;
            currentYear++;
          }
        });

        context.read<CalenderBloc>().add(
              GetAllDates(
                taskname: taskList[taskNumber],
                month: currentMonth,
                year: currentYear,
              ),
            );
      },
      child: Column(
        children: [
          Text(
            "${months[cm]} $cy",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: days
                  .map(
                    (e) => Text(
                      e.substring(0, 3).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
