import 'package:drift/drift.dart';
import 'package:initial_project/floor/databaseSuffix.dart';
import 'package:initial_project/floor/task/task.dart';

import 'base_daoSuffix.dart';
import 'task/taskSuffix.dart';

part 'task_daoSuffix.g.dart';

@DriftAccessor(tables: [ExampleTasks])
class ExampleTaskDao extends DatabaseAccessor<ExampleDatabase>
    with
        ExampleBaseDaoMixin<$ExampleTasksTable, ExampleTask>,
        _$ExampleTaskDaoMixin {
  ExampleTaskDao(super.db);

  Future<ExampleTask?> findTaskById(int id) {
    return (select(exampleTasks)
          ..where((exampleTasks) => exampleTasks.id.equalsExp(Variable(id))))
        .getSingle();
  }

  Future<List<ExampleTask>> getAllForUser(int userId) {
    return (select(exampleTasks)..where(
          (exampleTasks) => exampleTasks.userId.equalsExp(Variable(userId)),
        ))
        .get();
  }

  Future<void> add(ExampleTask task) async {
    await exampleTasks.insertOne(task);
  }

  Future<List<int>> saveMany(List<ExampleTask> many) async {
    await exampleTasks.insertAll(mode: InsertMode.replace, many);
    return const [];
  }

  Future<void> updateTask(ExampleTask task) async {
    await update(exampleTasks).replace(task);
  }

  Future<int> updateMany(List<ExampleTask> many) async {
    await batch((batch) {
      batch.replaceAll(exampleTasks, many);
    });
    return -1;
  }

  Future<int> deleteMany(List<ExampleTask> many) async {
    await batch((batch) {
      for (final entry in many) {
        batch.delete(exampleTasks, entry);
      }
    });
    return -1;
  }

  Future<int> deleteSolo(ExampleTask solo) async {
    return await delete(exampleTasks).delete(solo);
  }
}
