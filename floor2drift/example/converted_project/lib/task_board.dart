import 'package:flutter/material.dart';
import 'package:initial_project/floor/task/task.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/task_item.dart';

import 'floor/database_drift.dart';

class TaskBoard extends StatefulWidget {
  final ExampleDatabase database;
  final ExampleUser user;

  const TaskBoard({super.key, required this.database, required this.user});

  @override
  State<TaskBoard> createState() => _TaskBoardState();
}

class _TaskBoardState extends State<TaskBoard> {
  late List<Widget> taskWidgets = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Widget>> loadTasks() async {
    // just ignore that id can be null
    final tasks = await widget.database.exampleTaskDao.getAllForUser(
      widget.user.id!,
    );
    taskWidgets = tasks.map((s) => getTaskWidget(s)).toList();
    return taskWidgets;
  }

  Widget getTaskWidget(ExampleTask task) {
    return TaskItem(task: task, database: widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadTasks(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: ListView(children: taskWidgets),
            floatingActionButton: FloatingActionButton(
              onPressed: addNewTask,
              child: Icon(Icons.add),
            ),
          );
        }

        return CircularProgressIndicator();
      },
    );
  }

  void addNewTask() async {
    final newMessage = await showDialog<String?>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add new Task'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Task Message"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
            ),
          ],
        );
      },
    );

    if (newMessage == null) {
      return;
    }

    await widget.database.exampleTaskDao.add(
      ExampleTask.open(userId: widget.user.id!, message: newMessage),
    );

    setState(() {
      loadTasks();
    });
  }
}
