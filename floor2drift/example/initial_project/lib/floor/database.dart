import 'dart:async';
import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/floor/user_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'task_dao.dart';
import 'enums.dart';
import 'task.dart';
import 'type_converters.dart';

part 'database.g.dart';

@Database(version: 2, entities: [ExampleTask, ExampleUser])
@TypeConverters([TaskTypeConverter])
abstract class ExampleDatabase extends FloorDatabase {
  ExampleTaskDao get taskDao;

  ExampleUserDao get userDao;
}
