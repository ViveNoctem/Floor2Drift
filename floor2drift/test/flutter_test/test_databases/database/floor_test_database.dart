import 'dart:async';
import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../dao/floor_task_dao.dart';
import '../dao/test_entity_dao.dart';
import '../entities/task.dart';
import '../entities/test_entity.dart';
import '../support_classes/enums.dart';
import '../type_converters/type_converters.dart';

part 'floor_test_database.g.dart';

@Database(version: 1, entities: [TestTask, TestUser, TestEntity])
@TypeConverters([DateTimeConverter2, TaskTypeConverter])
abstract class FloorTestDatabase extends FloorDatabase {
  TestTaskDao get taskDao;

  EmptyTestTaskDao get emptytaskDao;

  TestEntityDao get testEntityDao;
}
