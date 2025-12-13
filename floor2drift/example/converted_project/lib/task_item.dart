import 'package:flutter/material.dart';
import 'package:initial_project/floor/enums.dart';
import 'package:initial_project/floor/task/task.dart';

import 'floor/database_drift.dart';

class TaskItem extends StatefulWidget {
  final ExampleTask task;
  final ExampleDatabase database;

  TaskItem({super.key, required this.task, required this.database});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late ExampleTask stateTask;

  @override
  void initState() {
    super.initState();
    stateTask = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: getCheckBoxValue(stateTask.status),
          tristate: true,
          onChanged: (value) async {
            setState(() {
              stateTask = widget.task.copyWith(status: getTaskStatus(value));
            });
            await widget.database.exampleTaskDao.updateTask(stateTask);
          },
        ),
        Text(widget.task.message),
        SizedBox(width: 30),
        Text(widget.task.timestamp.toIso8601String()),
      ],
    );
  }

  TaskStatus getTaskStatus(bool? value) {
    return switch (value) {
      false => TaskStatus.open,
      null => TaskStatus.inProgress,
      true => TaskStatus.done,
    };
  }

  bool? getCheckBoxValue(TaskStatus status) {
    return switch (status) {
      TaskStatus.open => false,
      TaskStatus.inProgress => null,
      TaskStatus.done => true,
    };
  }
}
