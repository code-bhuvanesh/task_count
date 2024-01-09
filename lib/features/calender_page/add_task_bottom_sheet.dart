import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_count/features/calender_page/bloc/calender_bloc.dart';

class AddTaskSheet extends StatefulWidget {
  final ScrollController scrollController;
  final double sheetHeight;
  final double topPadding;
  const AddTaskSheet({
    required this.scrollController,
    required this.sheetHeight,
    required this.topPadding,
    super.key,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  @override
  void initState() {
    context.read<CalenderBloc>().add(GetTasksList());
    super.initState();
  }

  double radiusSize = 0;
  double sa = 0;

  List<String> tasksList = [];
  @override
  Widget build(BuildContext context) {
    if (widget.sheetHeight > 0.8) {
      setState(() {
        radiusSize = 0;
        sa = widget.topPadding;
      });
    } else {
      setState(() {
        radiusSize = 50 * widget.sheetHeight;
        sa = 0;
      });
    }
    return BlocListener<CalenderBloc, CalenderState>(
      listener: (context, state) {
        if (state is TasksList) {
          setState(() {
            tasksList = state.tasklist;
          });
        } else if (state is NewTaskAdded) {
          setState(() {
            tasksList.add(state.newTask);
          });
        } else if (state is TaskExists) {
          showTasksExistError(state.taskname);
        }
      },
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusSize),
            gradient: const LinearGradient(
              colors: [Colors.transparent, Color.fromARGB(40, 0, 0, 0)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          height: double.infinity,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                radiusSize,
              ),
            ),
            elevation: 10,
            margin: const EdgeInsets.only(top: 4),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: sa,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tasks",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        addTaskButton(Icons.add),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: tasksList.map((e) => taskWidget(e)).toList(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addTaskButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      margin: const EdgeInsets.all(10),
      child: IconButton(
        onPressed: () {
          setState(() {
            taskDialog(context);
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

  Widget taskWidget(String taskName) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  taskName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.start,
                ),
                GestureDetector(
                  onTap: () {
                    taskDialog(
                      context,
                      updateTask: true,
                      taskName: taskName,
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.draw),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider()
        ],
      ),
    );
  }

  Future<void> showTasksExistError(String taskname) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: "Add Task",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 240,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "\"$taskname\" already exists!",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 236, 230, 246),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(
                          // color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween =
            Tween(begin: const Offset(0, 1), end: Offset.zero);

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
    if (mounted) context.read<CalenderBloc>().add(GetTasksList());
  }

  Future<void> taskDialog(BuildContext context,
      {bool updateTask = false, String taskName = ""}) async {
    var taskController = TextEditingController(text: taskName);
    await showGeneralDialog(
      context: context,
      barrierLabel: !updateTask ? "Add Task" : "update task",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 240,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    !updateTask ? "Add Task" : "Update Task",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: "New Task Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 236, 230, 246),
                      ),
                    ),
                    onPressed: () {
                      if (!updateTask) {
                        context.read<CalenderBloc>().add(
                              AddNewTask(taskName: taskController.text),
                            );
                      } else {
                        context.read<CalenderBloc>().add(
                              UpdateTaskName(
                                newTaskName: taskController.text,
                                oldTaskName: taskName,
                              ),
                            );
                      }

                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                          // color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween =
            Tween(begin: const Offset(0, 1), end: Offset.zero);

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
    if (mounted) context.read<CalenderBloc>().add(GetTasksList());
  }
}
