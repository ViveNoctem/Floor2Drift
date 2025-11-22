import 'package:drift/drift.dart';
import 'package:initial_project/floor/task/task.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/floor/userSuffix.dart';
import 'package:initial_project/floor/user_daoSuffix.dart';

import 'enums.dart';
import 'task/taskSuffix.dart';
import 'task_daoSuffix.dart';
import 'type_convertersSuffix.dart';

part 'databaseSuffix.g.dart';

@DriftDatabase(
  tables: [ExampleTasks, ExampleUsers],
  daos: [ExampleTaskDao, ExampleUserDao],
)
class ExampleDatabase extends _$ExampleDatabase {
  ExampleDatabase(super.e);

  @override
  int get schemaVersion => 2;
}
