import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_count/features/calender_page/bloc/calender_bloc.dart';

class AddNoteSheet extends StatefulWidget {
  final ScrollController scrollController;
  final double sheetHeight;
  final double topPadding;
  final TextEditingController notesController;
  final String taskname;
  final DateTime date;
  const AddNoteSheet({
    required this.scrollController,
    required this.sheetHeight,
    required this.topPadding,
    required this.notesController,
    required this.taskname,
    required this.date,
    super.key,
  });

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  @override
  void initState() {
    context.read<CalenderBloc>().add(
          GetNote(
            taskName: widget.taskname,
            date: widget.date,
          ),
        );
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
        sa = widget.topPadding * widget.sheetHeight;
      });
    } else {
      setState(() {
        radiusSize = 50 * widget.sheetHeight;
        sa = 20;
      });
    }
    print("top padding : $sa :  ${widget.sheetHeight}");
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            blurRadius: 7.0,
            offset: Offset(3.5, 0),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusSize),
          topRight: Radius.circular(radiusSize),
        ),
      ),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusSize),
            topRight: Radius.circular(radiusSize),
          ),
        ),
        elevation: 10,
        margin: const EdgeInsets.only(top: 4),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: sa),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Add a Note",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    maxLines: 1000,
                    controller: widget.notesController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "First line will be taken as title...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
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
