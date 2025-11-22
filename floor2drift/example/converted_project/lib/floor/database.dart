import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:floor/floor.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/floor/user_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'enums.dart';
import 'task/task.dart';
import 'task_dao.dart';
import 'type_converters.dart';

part 'database.g.dart';

@Database(version: 2, entities: [ExampleTask, ExampleUser])
@TypeConverters([TaskTypeConverter])
abstract class ExampleDatabase extends FloorDatabase {
  ExampleTaskDao get taskDao;

  ExampleUserDao get userDao;
}

// @DriftDatabase(tables: [ExampleTasks, ExampleUsers], daos: [ExampleTaskDao])
// class Database extends _$Database {
//   Database(super.e);
//
//   @override
//   int get schemaVersion => 1;
//
//   @override
//   MigrationStrategy get migration {
//     return MigrationStrategy(
//       onCreate: (Migrator m) async {
//         await m.createAll();
//       },
//       onUpgrade: (Migrator m, int from, int to) async {
//         m.database.customStatement("");
//         m.database.customInsert(query)
//       },
//     );
//   }
// }
