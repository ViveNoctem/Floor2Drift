import 'package:floor/floor.dart';
// ignore: unused_import needed to test if table is being hidden
import "package:flutter/cupertino.dart";
// ignore: unused_import needed to test if table is being hidden
import 'package:flutter/material.dart';

import '../entities/task.dart';
import '../support_classes/enums.dart';
import 'floor_base_task_dao.dart';

@dao
abstract class TestEntityDao {
  @Query("SELECT type FROM entityENTITY WHERE type = :argument")
  Future<List<TaskType>> columnCasingWrong(TaskType argument);

// TODO TypeConverter between 2 native sql type doesn't see to work in floor
// @Query("SELECT stringConverted FROM entityEntity WHERE stringConverted = :message")
// Future<List<Uint8List>> getBase64String(String message);
}

@dao
abstract class EmptyTestTaskDao extends BaseDao<TestTask> {}
