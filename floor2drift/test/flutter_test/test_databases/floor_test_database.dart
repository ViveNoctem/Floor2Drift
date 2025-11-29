import 'dart:async';
import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'enums.dart';
import 'floor_task_dao.dart';
import 'task.dart';
import 'type_converters.dart';

part 'floor_test_database.g.dart';

@Database(version: 1, entities: [TestTask, TestUser])
@TypeConverters([DateTimeConverter2, TaskTypeConverter])
abstract class FloorTestDatabase extends FloorDatabase {
  TestTaskDao get taskDao;
}
